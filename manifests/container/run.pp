define teneleven::container::run (
  $image        = 'base',
  $hostname     = $title,
  $net          = 'web',
  $volumes      = [],
  $volumes_from = [],
  $depends      = undef,
  $puppet_mount = '/puppet',
  $expose       = [],
  $ports        = [],
  $env          = [],
  $provision    = false,
) {
  docker::run { $title:
    image    => 'base',
    hostname => $hostname,
    net      => $net,
    depends  => $depends,
    expose   => $expose,
    ports    => $ports,
    env      => concat(['FACTER_is_container=1'], $env),

    volumes_from => $volumes_from,
    volumes      => $::puppet_dir ? {
      /* mount /puppet using puppet_dir fact */
      default => concat($volumes, ["${::puppet_dir}:${puppet_mount}"]),
      undef   => $volumes
    },
  }
  -> docker::exec { "${title}-provision":
       container => $title,
       command   => $provision ? {
         true  => '/provision.sh',
         false => 'true'
       }
     }
}
