/**
 * Run a container using docker::run
 *
 * If puppet_dir fact is set, also mounts the puppet dir using the puppet_dir fact
 */
define teneleven::container::run (
  $options      = {},        /* docker options */
  $puppet_mount = $teneleven::params::puppet_mount,

  $default_hostname = $title,
  $default_image    = 'base',
  $default_net      = 'web',
  $default_env      = ['FACTER_is_container=1'],
) {
  include ::teneleven::params
  include ::teneleven::container::base

  $full_options = merge({
    hostname => $default_hostname,
    image    => $default_image,
    net      => $default_net,
    env      => $default_env,
  }, $options, {
    volumes  => $options['volumes'] ? {
      default => concat(["${::puppet_dir}:${puppet_mount}"], $options['volumes']),
      undef   => ["${::puppet_dir}:${puppet_mount}"]
    }
  })

  create_resources('::docker::run', { $title => $full_options })

  if ($options['depends']) {
    Docker::Run[$options['depends']] -> Docker::Run[$title]
  }
}
