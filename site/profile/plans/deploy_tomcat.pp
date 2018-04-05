plan profile::deploy_tomcat (
  TargetSpec $app_servers,
  String $deploy_location,
  String $artifactory_base,
  String $repository,
  String $token,
){

  # name, version, group
  $details = profile::loaddata('app.yaml')

  run_task('profile::get_gavc', $app_servers,
    artifactid        => $details['name'],
    version           => $details['version'],
    group             => $details['group'],
    repository        => $repository,
    deploy_location   => $deploy_location,
    artifactory_host  => $artifactory_base,
    apitoken          => $token
  )

}
