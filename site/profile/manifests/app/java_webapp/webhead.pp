# Setup a new Tomcat Webhead and add to LB; no app deployed here
class profile::app::java_webapp::webhead (
  $app_env = pick($::java_webapp, 'dev')
) {

  if $::kernel != 'Linux' {
    fail('Unsupported OS')
  }

  include ::profile::app::puppet_tomcat


  @@haproxy::balancermember { "haproxy-java_webapp-${::fqdn}":
    listening_service => "${app_env}_java_webapp_bk",
    ports             => '8080',
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress,
    options           => 'check',
  }

}
