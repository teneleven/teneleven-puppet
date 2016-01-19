define teneleven::container::provision (
  $hostname     = $title,
  $image        = 'base',
  $net          = 'web',
  $puppet_mount = '/puppet',
  $volumes      = [],
  $volumes_from = [],

  $docker_options = {},
) {
  contain ::teneleven::container::base

  ::teneleven::container::run { $title:
    hostname       => $hostname,
    image          => $image,
    net            => $net,
    puppet_mount   => $puppet_mount,
    volumes        => $volumes,
    volumes_from   => $volumes_from,
    docker_options => $docker_options,
  }
    -> ::docker::exec { "${title}-provision":
      container => $hostname,
      command   => '/provision.sh',
      detach    => true,
    }
}
