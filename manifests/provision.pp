class teneleven::provision (
  $apps = {},

  /* one of "docker-compose", "docker", or "puppet" */
  $provision_with = 'docker-compose'
) {

  if $provision_with == 'docker-compose' {
    $apps.each |$app_name, $app_type| {
      create_resources('teneleven::docker::compose', { $app_name => {
        app_type => $app_type
      } })
    }
  } elsif $provision_with == 'docker' {
    $apps.each |$app_name, $app_type| {
      create_resources('teneleven::docker::provision', { $app_name => {
        env => ["FACTER_project_name=${app_name}", "FACTER_app_type=${app_type}"]
      } })
    }
  } elsif $provision_with == 'puppet' {
    $apps.each |$app_name, $app_type| {
      exec { "provision-${app_name}":
        command => 'sh -c "./provision.sh; supervisord -n"',
        environment => ["FACTER_project_name=${app_name}", "FACTER_app_type=${app_type}"],
        path => ['/bin', '/usr/bin']
      }
    }
  } else {
    fail('Invalid provision_with param passed to teneleven::provision - must be one of "docker-compose", "docker", or "puppet"')
  }

}
