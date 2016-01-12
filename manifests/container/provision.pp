define teneleven::container::provision (
  $hostname   = $title,
  $net        = 'web',
  $image      = 'base',
  $puppet_dir = undef, /* use teneleven::container::base::dir by default */
  $volumes    = []
) {
  contain teneleven::container::base

  /* uses cwd fact from provision.sh (wherever script is exec'd from) */
  $full_puppet_dir = $puppet_dir ? {
    default => "${cwd}/${puppet_dir}",
    undef   => "${cwd}/${teneleven::container::base::dir}"
  }

  docker::run { $title:
    image    => 'base',
    hostname => $hostname,
    net      => $net,
    volumes  => concat($volumes, ["${full_puppet_dir}:/puppet"]),
  }

}
