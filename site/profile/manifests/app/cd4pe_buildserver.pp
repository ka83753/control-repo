class profile::app::cd4pe_buildserver {
  case $::kernel {
    'Linux':   {  include ::profile::app::cd4pe_buildserver::linux }
    'windows': {  include ::profile::app::cd4pe_buildserver::windows }
    default:   { fail('Unsupported OS') }
  }
}
