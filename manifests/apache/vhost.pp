/**
 * Vhost helper with defaults for symfony site.
 */
define teneleven::apache::vhost (
  $options = {},

  $default_port  = 80,
  $default_owner = 'www-data',
  $docroot_group = 'www-data'
) {
  create_resources('::apache::vhost', { $title => merge({
    port => 80,
    docroot_owner => $default_owner,
    docroot_group => $default_group,
  }, $options) })
}
