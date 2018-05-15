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

  include ::rbenv
  rbenv::plugin { 'rbenv/ruby-build': }
  rbenv::build { $ruby_version: global    => true }

}
