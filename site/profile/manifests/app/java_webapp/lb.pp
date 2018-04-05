# Setup a new HA proxy instance for java webapp
class profile::app::java_webapp::lb (
  $dev_hostname  = 'dev-java-app.puppet.vm',
  $prod_hostname = 'prod-java-app.puppet.vm',
){

  require ::profile::app::haproxy

  haproxy::mapfile { 'domains-to-backends':
    ensure   => 'present',
    mappings => [
      { $dev_hostname  => 'dev_java_webapp_bk' },
      { $prod_hostname => 'prod_java_webapp_bk' },
    ],
  }

  haproxy::frontend { 'allapps':
    ipaddress => '0.0.0.0',
    ports     => '80',
    mode      => 'http',
    options   => {
      'use_backend' => [
        "dev_java_webapp_bk if { hdr(Host) -i ${dev_hostname} }",
        "prod_java_webapp_bk if { hdr(Host) -i ${prod_hostname} }",
      ],
    },
  }

  haproxy::backend { 'dev_java_webapp_bk':
    mode    => 'http',
    options => {
      'option'  => [
        'tcplog',
      ],
      'balance' => 'roundrobin',
    },
  }

  haproxy::backend { 'prod_java_webapp_bk':
    mode    => 'http',
    options => {
      'option'  => [
        'tcplog',
      ],
      'balance' => 'roundrobin',
    },
  }

  Haproxy::Balancermember <<| listening_service == 'dev_java_webapp_bk' |>>
  Haproxy::Balancermember <<| listening_service == 'prod_java_webapp_bk' |>>

  firewall { '111 allow http 80 access':
    dport  => 80,
    proto  => tcp,
    action => accept,
  }

}
