/**
 * Run a container using docker::run
 *
 * If puppet_dir fact is set, also mounts the puppet dir using the puppet_dir fact
 */
define teneleven::container::run (
  $options      = {},        /* docker options */
  $puppet_mount = undef,

  $default_hostname = $title,
  $default_image    = 'base',
  $default_env      = ['FACTER_is_container=1'],
) {
  include ::teneleven::params
  include ::teneleven::container::base

  $real_puppet_mount = $puppet_mount ? {
    default => $puppet_mount,
    undef   => $::teneleven::params::puppet_mount
  }

  $default_options = {
    hostname                  => $default_hostname,
    image                     => $default_image,
    remove_container_on_start => true,
    remove_container_on_stop  => true,
  }

  $volumes = $options['volumes'] ? {
    default => concat(["${::puppet_dir}:${real_puppet_mount}"], $options['volumes']),
    undef   => ["${::puppet_dir}:${real_puppet_mount}"]
  }

  $env = $options['env'] ? {
    default => concat($default_env, $options['env']),
    undef   => $default_env
  }

  create_resources('::docker::run', { $title => merge($default_options, $options, { volumes => $volumes }, { env => $env }) })

  if ($options['depends']) {
    Docker::Run[$options['depends']] -> Docker::Run[$title]
  }
}
