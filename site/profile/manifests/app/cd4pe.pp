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


  docker::run {'cd4pe-artifactory':
    image   => 'docker.bintray.io/jfrog/artifactory-oss:5.8.3',
    ports   => ['8081:8081'],
    volumes => ['cd4pe-artifactory:/var/opt/jfrog/artifactory'],
  }

  docker::run {'cd4pe-mysql':
    image     => 'mysql:5.7',
    ports     => ['3306:3306'],
    volumes   => ['cd4pe-mysql:/var/lib/mysql'],
    env_file  => ['/etc/cd4pe/mysql_env'],
    subscribe => File['/etc/cd4pe/mysql_env'],

  }

  docker::run {'cd4pe':
    image     => "pcr-internal.puppet.net/pipelines/pfi:${cd4pe_version}",
    ports     => ['8080:8080','8000:8000','7000:7000'],
    volumes   => ['/var/lib/mysql'],
    env_file  => [
      '/etc/cd4pe/env',
      '/etc/cd4pe/secret_key',
    ],
    links     => [
      'cd4pe-mysql:db',
      'cd4pe-artifactory:artifactory',
    ],
    subscribe => [
      File['/etc/cd4pe/env'],
    ],
    require   => [
      Docker::Run['cd4pe-artifactory'],
      Docker::Run['cd4pe-mysql'],
      File['/etc/cd4pe/secret_key'],
    ]
  }
}
