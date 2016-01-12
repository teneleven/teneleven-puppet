define teneleven::container::provision (
  $hostname     = $title,
  $net          = 'web',
  $image        = 'base',
  $volumes      = [],
  $depends      = undef,
  $puppet_mount = '/puppet',
  $expose       = [],
  $ports        = [],
) {
  docker::run { $title:
    image    => 'base',
    hostname => $hostname,
    net      => $net,
    volumes  => $::puppet_dir ? {
      /* mount /puppet using puppet_dir fact */
      default => concat($volumes, ["${::puppet_dir}:${puppet_mount}"]),
      undef   => $volumes
    },
    depends  => $depends,
    expose   => $expose,
    ports    => $ports,
  }
}
