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
      $app_hosts = $app['hosts'] ? {
        undef   => $app_default_hosts,
        default => $app['hosts']
      }

      $provision_args = merge({
        app_type  => $app['app'],
        app_hosts => $app_hosts
      }, delete($app, ['app', 'hosts']))
    } else {
      $provision_args = {
        app_type  => $app,
        app_hosts => $app_default_hosts
      }
    }

    create_resources("teneleven::provision::${provision_with}", { $app_name => $provision_args })
  }

}
