/**
 * Run a container using docker::run
 *
 * If puppet_dir fact is set, also mounts the puppet dir using the puppet_dir fact
 */
define teneleven::container::run (
  $hostname     = $title,
  $image        = 'base',
  $net          = 'web',
  $puppet_mount = '/puppet', /* destination mount on the container */
  $volumes      = [],
  $volumes_from = [],
  $default_env  = ['FACTER_is_container=1'],

  /* extra docker options passed to docker::run - set env variables, etc. here */
  $docker_options = {},
) {
  contain ::teneleven::container::base

  /* mount /puppet using puppet_dir fact, if the fact is set */
  $real_volumes = $::puppet_dir ? {
    default    => concat($volumes, ["${::puppet_dir}:${puppet_mount}"]),
    undef      => $volumes
  }

  $real_env = $docker_options['env'] ? {
    default => concat($default_env, $docker_options['env']),
    undef   => $default_env,
  }

  $full_docker_options = merge($docker_options, {
    hostname     => $hostname,
    image        => $image,
    volumes_from => $volumes_from,
    volumes      => $real_volumes,
    net          => $net,
    env          => $real_env,
  })

  create_resources('::docker::run', { $title => $full_docker_options })
}
