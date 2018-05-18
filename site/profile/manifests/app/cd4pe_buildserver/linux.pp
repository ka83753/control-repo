class profile::app::cd4pe_buildserver::linux(
  String $ruby_version = '2.4.4',
) {

  unless $::osfamily == 'RedHat' or $::osfamily == 'Debian' {
    fail("Unsupported OS ${::osfamily}")
  }

  include ::pdk

  $dev_packages = $::osfamily ? {
    'RedHat' => ['gcc','gcc-c++','openssl-devel','readline-devel','zlib-devel','cmake'],
    'Debian' => ['build-essential','cmake','libssl-dev','zlib1g-dev','libreadline6-dev'],
  }

  ensure_packages($dev_packages,{ensure => present})


  # Create the user for distelli
  user {'distelli':
    ensure     => 'present',
    managehome => true,
  }

  file {'/home/distelli/.ssh':
    ensure  => directory,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0700',
    require => User['distelli'],
  }

  file {'/home/distelli/.ssh/config':
    ensure  => present,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0600',
    source  => 'puppet:///modules/profile/app/cd4pe_buildserver/distelli.ssh.config',
    require => User['distelli'],
  }

  class{'::rbenv':
    owner       => 'distelli',
    install_dir => '/distelli/rbenv',
    require     => [
      User['distelli'],
    ]
  }

  rbenv::plugin { 'rbenv/ruby-build': }
  rbenv::build { $ruby_version: global => false }

}
