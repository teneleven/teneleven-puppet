/**
 * Vhost helper with defaults for symfony site.
 */
define teneleven::apache::vhost (
  $options = {},

  $port          = undef,
  $default_owner = 'www-data',
  $docroot_group = 'www-data'
) {
  include ::teneleven::apache

  $real_port = $port ? {
    undef   => $::teneleven::apache::port,
    default => $port
  }

  create_resources('::apache::vhost', { $title => merge({
    port          => $real_port,
    docroot_owner => $default_owner,
    docroot_group => $default_group,
  }, $options) })
}
