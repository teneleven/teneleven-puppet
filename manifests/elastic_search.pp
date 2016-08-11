class teneleven::elastic_search (
  $settings = {},

  $default_settings = {
    java_install => true
  }
) inherits teneleven::params {

  create_resources('class', { 'elasticsearch' => merge(
    $default_settings,
    $settings
  )})

}
