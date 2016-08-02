class teneleven::provision (
  $apps = {},

  /* one of *.pp files in provision subfolder */
  $provision_with = 'docker_compose',

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
      $extra_options = delete($app, ['app', 'hosts'])
    } else {
      $app_type  = $app
      $app_hosts = $app_default_hosts
      $extra_options = {}
    }

    if (is_array($app_hosts)) {
      $app_hosts_str = join($app_hosts, ',')
    } elsif (is_string($app_hosts)) {
      $app_hosts_str = $app_hosts
    } else {
      fail('Invalid app_hosts type passed to teneleven::provision')
    }

    /* start container first, if we're using docker */
    if ($provision_with == 'docker') {
      teneleven::docker::run { $app_name:
        app_type => $app_type,
        options  => { env => [
          "FACTER_project_name=${app_name}",
          "FACTER_app_type=${app_type}",
          "FACTER_app_hosts=${app_hosts_str}"
        ]}
      }
    } elsif ($provision_with == 'docker_compose') {
      teneleven::docker::compose { $app_name:
        app_type => $app_type,
        env      => ["COMPOSE_APP_TYPE=${app_type}", "COMPOSE_APP_HOSTS=${app_hosts_str}"]
      }
    }

    if ($provision_with == 'shell') {
      $provision_args = merge({
        env       => ["FACTER_project_name=${app_name}", "FACTER_app_type=${app_type}", "FACTER_app_hosts=${app_hosts_str}"],
      }, $extra_options)
    } else {
      $provision_args = $extra_options
    }

    notice("Provisioning ${app_name}...")

    create_resources("teneleven::provision::${provision_with}", { $app_name => $provision_args })
  }

}
