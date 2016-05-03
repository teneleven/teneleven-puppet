class teneleven::provision (
  $apps = {},

  /* one of "docker-compose", "docker", or "puppet" */
  $provision_with = 'docker-compose',

  /* replaces ${project_name} with app's hash key */
  $default_hosts = '%{project_name}.docker'
) {

  $apps.each |$app_name, $app| {
    $app_default_hosts = regsubst($default_hosts, '\$\{project_name\}', $app_name, 'GI')

    if (is_hash($app)) {
      $app_type = $app['app']
      $app_hosts = $app['hosts'] ? {
        undef   => $app_default_hosts,
        default => $app['hosts']
      }
    } else {
      $app_type = $app
      $app_hosts = $app_default_hosts
    }

    if $provision_with == 'docker-compose' {
      $compose_hosts = join($app_hosts, ',')
      create_resources('teneleven::docker::compose', { $app_name => {
        app_type => $app_type,
        env => ["COMPOSE_APP_TYPE=${app_type}", "COMPOSE_APP_HOSTS=${compose_hosts}"]
      } })
    } elsif $provision_with == 'docker' {
      /* FIXME this won't work with array app_hosts */
      create_resources('teneleven::docker::provision', { $app_name => {
        env => ["FACTER_project_name=${app_name}", "FACTER_app_type=${app_type}", "FACTER_app_hosts=${app_hosts}"]
      } })
    } elsif $provision_with == 'puppet' {
      exec { "provision-${app_name}":
        command => 'sh -c "./provision.sh; supervisord -n"',
        environment => ["FACTER_project_name=${app_name}", "FACTER_app_type=${app_type}", "FACTER_app_hosts=${app_hosts}"],
        path => ['/bin', '/usr/bin']
      }
    } else {
      fail('Invalid provision_with param passed to teneleven::provision - must be one of "docker-compose", "docker", or "puppet"')
    }
  }

}
