define teneleven::container::provision (
  $hostname     = $title,
  $puppet_mount = '/puppet',
  $volumes      = [],
  $volumes_from = [],

  $docker_options = {},
) {
  contain teneleven::container::base

  $full_docker_options = merge({
    hostname     => $hostname,
    volumes_from => $volumes_from,
    volumes      => $::puppet_dir ? {
      /* mount /puppet using puppet_dir fact */
      default => concat($volumes, ["${::puppet_dir}:${puppet_mount}"]),
      undef   => $volumes
    },
    provision    => true
  }, $docker_options)

  create_resources('::teneleven::container::run', { $title => $full_docker_options })
}
