class profile::app::cd4pe (
  String $cd4pe_version = '393411',
  String $db_name = 'cd4pe',
  String $db_user = 'cd4pe',
  String $db_pass = 'cd4pe',
){
  require ::profile::platform::baseline
  require ::profile::app::docker

  file {'/etc/cd4pe':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  $data = {
    db_name    => $db_name,
    db_user    => $db_user,
    db_pass    => $db_pass,
  }

  file {'/etc/cd4pe/env':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => epp('profile/app/cd4pe.env.epp', $data),
  }

  $secret_key = profile::secure16()
  file {'/etc/cd4pe/secret_key':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => "PFI_SECRET_KEY=${secret_key}",
    replace => false,
  }

  file {'/etc/cd4pe/mysql_env':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => epp('profile/app/cd4pe.mysql_env.epp', $data),
  }

  file {'/etc/cd4pe/gitlab_env':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => epp('profile/app/gitlab.env.epp', { fqdn => $::fqdn }),
  }

  docker_network {'cd4pe':
    ensure => present,
  }

  docker::run {'gitlab':
    image   => 'gitlab/gitlab-ce:latest',
    ports   => ['443:443','80:80','2222:22'],
    volumes => [
      'gitlab-config:/etc/gitlab',
      'gitlab-var:/var/log/gitlab',
      'gitlab-data:/var/opt/gitlab',
    ],
    net     => 'cd4pe',
  }

  docker::run {'artifactory':
    image   => 'docker.bintray.io/jfrog/artifactory-oss:5.8.3',
    ports   => ['8081:8081'],
    volumes => ['cd4pe-artifactory:/var/opt/jfrog/artifactory'],
    net     => 'cd4pe',
  }

  docker::run {'db':
    image     => 'mysql:5.7',
    net       => 'cd4pe',
    ports     => ['3306:3306'],
    volumes   => ['cd4pe-mysql:/var/lib/mysql'],
    env_file  => ['/etc/cd4pe/mysql_env'],
    subscribe => File['/etc/cd4pe/mysql_env'],
  }

  $master_server = $::settings::server
  $master_query = "facts[value]{ name = 'ipaddress' and certname = \'${master_server}\'}"
  $master_ip = puppetdb_query($master_query)[0]['value']

  docker::run {'cd4pe.pdx.puppet.vm':
    image            => "pcr-internal.puppet.net/pipelines/pfi:${cd4pe_version}",
    extra_parameters => ["--add-host ${master_server}:${master_ip}"],
    ports            => ['8080:8080','8000:8000','7000:7000'],
    volumes          => ['/var/lib/mysql'],
    env_file         => [
      '/etc/cd4pe/env',
      '/etc/cd4pe/secret_key',
    ],
    net              => 'cd4pe',
    subscribe        => [
      File['/etc/cd4pe/env'],
    ],
    require          => [
      Docker::Run['artifactory'],
      Docker::Run['db'],
      Docker::Run['gitlab'],
      File['/etc/cd4pe/secret_key'],
    ]
  }

}
