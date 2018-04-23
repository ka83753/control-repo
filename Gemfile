source 'https://rubygems.org'

case RUBY_PLATFORM
when /darwin/
  gem 'CFPropertyList'
end

gem 'puppet', '< 5.0.0'
gem 'puppetlabs_spec_helper'
gem 'semantic_puppet'
gem 'ra10ke'
gem 'rubocop'
gem 'rubocop-rspec'
gem 'rest-client'
gem 'facter', '2.4.6'
gem 'r10k', '>= 2.5.5'
gem 'rake'

group :development, :unit_tests do
  gem 'metadata-json-lint'
  gem 'rspec-puppet-facts', :git => 'https://github.com/mcanevet/rspec-puppet-facts.git',
                      :ref => 'fe21de12108fbab0123bdc4db2365a29ea62f171'
  gem 'puppet-blacksmith', '>= 3.4.0'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git',
                      :ref => 'eaba657a8e876c8c4a881a6d47df76cfdda62b3f'
  gem 'puppet-syntax', '>= 2.4.0'
  gem 'parallel_tests'
  gem 'json'
  gem 'onceover'
  gem 'hiera-eyaml'
end

