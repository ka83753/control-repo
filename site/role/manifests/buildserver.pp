# @summary This role installs a Pipelines Buildserver (Cd4PE)
class role::buildserver {
  include ::profile::platform::baseline
  if $::kernel == 'Linux' {
    include ::profile::app::cd4pe_buildserver::linux
  }
  elsif $::kernel == 'windows' {
    include ::profile::app::cd4pe_buildserver::linux
  }
}
