if $::new_repo == undef {
  fail("You need to set FACTER_new_repo='XXXXX' and THEN run this")
}

notify {'Switching Control Repo; this will take some time....':}
node_group { 'PE Master':
  ensure               => 'present',
  classes              => {
    'pe_repo'                            => {},
    'pe_repo::platform::el_7_x86_64'     => {},
    'pe_repo::platform::windows_x86_64'  => {},
    'puppet_enterprise::profile::master' => {
      'code_manager_auto_configure' => true,
      'r10k_private_key'            => '/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa',
      'r10k_remote'                 => $::new_repo,
      'replication_mode'            => 'none',
    },
  },
  environment          => 'production',
  # lint:ignore:quoted_booleans
  override_environment => 'false',
  # lint:endignore
  parent               => 'PE Infrastructure',
  rule                 => ['or',
  ['=', 'name', 'master.inf.puppet.vm']],
  notify               => Exec['run_puppet'],
}

notify {'Running Puppet to apply changes':}
exec {'run_puppet':
  command     => '/opt/puppetlabs/bin/puppet agent -t',
  returns     => [2],
  refreshonly => true,
  notify      => Exec['deploy_code'],
}

notify {'Deploying new control-repo code':}
exec {'deploy_code':
  command     => '/opt/puppetlabs/bin/puppet-code deploy --all -w',
  refreshonly => true,
}
