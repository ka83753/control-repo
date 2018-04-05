plan profile::deploy_tomcat (
  TargetSpec $app_servers,
  TargetSpec $lb,
  String $backend,
  String $deploy_location,
  String $artifactory_base,
  String $repository,
  String $token,
){

  # name, version, group
  $details = profile::loaddata('/var/tmp/app.yaml')

  profile::puts("Starting rolling deployment on app servers $app_servers...")

  $app_servers.split(',').each |$a| {

    profile::puts("\tDrain connections from member ${backend}:${a}")

    if run_task('profile::haproxy', "pcp://${lb}",
      action  => drain,
      server  => $a.split('\.')[0],
      socket  => '/var/lib/haproxy/stats',
      backend => $backend,
    ).ok() == true {
      profile::puts("\tConnections from member ${backend}:${a} drained successfully!")
    } else {
      fail("\tCouldn't drain connections from member ${backend}:${a}!")
    }

    if run_task('profile::get_gavc', $a,
      artifactid        => $details['name'],
      version           => $details['version'],
      group             => $details['group'],
      repository        => $repository,
      deploy_location   => $deploy_location,
      artifactory_host  => $artifactory_base,
      apitoken          => $token
    ).ok() == true {
      profile::puts("\tSuccessfully deployed ${details['name']} version ${details['version']} on host ${a}!")
    } else {
      fail("\tCouldn't deploy ${details['name']} on host ${a}!")
    }

    profile::sleep(10)

    profile::puts("\tRunning healthcheck on ${a}...")
    if run_task('profile::healthcheck', "pcp://${a}",
      port   => 8080,
      target => $a,
    ).ok() == true {
      profile::puts("\tSuccessfully updated ${a}!")
    } else {
      fail("\tHealthcheck failed for ${a}!")
    }

    profile::puts("\tRe-addding ${a} to backend ${backend}...")
    if run_task('profile::haproxy', "pcp://${lb}",
      action  => add,
      server  => $a.split('\.')[0],
      socket  => '/var/lib/haproxy/stats',
      backend => $backend,
    ).ok() == true {
      profile::puts("\tRe-addded ${a} to backend ${backend} successfully!")
    } else {
      fail("\tFailed to re-add ${a} to backend ${backend}!")
    }

  }

  profile::puts("Successfully completed rolling deployment on app servers $app_servers...")
}
