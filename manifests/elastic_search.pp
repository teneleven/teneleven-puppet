class teneleven::elastic_search (
  $settings = {},

  $instances = {} /* not required, will setup a default instance */
) inherits teneleven::params {

  $default_settings = {
    java_install => true,
    manage_repo  => true,
    repo_version => '2.x'
  }

  create_resources('class', { 'elasticsearch' => merge(
    $default_settings,
    $settings
  )})

  $instances.each |$name, $instance| {
    create_resources('elasticsearch::instance', { $name => $instance })
  }

  if (empty($instances)) {
    /* setup default instance */
    elasticsearch::instance { 'default': }
  }

}
