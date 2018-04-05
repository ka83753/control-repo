#!/opt/puppetlabs/puppet/bin/ruby

require 'net/http'
require 'uri'
require 'json'

def httpcall(url, token)
  uri = URI.parse(url)
  request = Net::HTTP::Get.new(uri)
  request.add_field('X-Jfrog-Art-Api', token)
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  response.body
end

# ---- <MAIN> ----
params = JSON.parse(STDIN.read)

deploy_location = params['deploy_location']
artifactory_base = params['artifactory_host']
repository = params['repository']
artifact = params['artifactid']
version = params['version']
group = params['group']
token = params['token']


begin
  result = {}
  fullurl = "#{artifactory_base}/api/search/gavc?g=#{group}&a=#{artifact}&v=#{version}&repos=#{repository}"
  response = httpcall(fullurl, token)

  raise('Artifact not found!') if JSON.parse(response).key?('errors')

  metadata = JSON.parse(response)['results'][-1]['uri']
  if !metadata.nil? || metadata != ''
    meta = JSON.parse(httpcall(metadata, token))
    open(deploy_location, 'wb') do |file|
      file.write(httpcall(meta['downloadUri'], token))
    end
    result['result'] = { success: true }
  end
rescue => e
  result[:_error] = { "msg" => e.message }
end
print(JSON.dump(result))
