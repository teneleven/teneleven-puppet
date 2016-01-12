define teneleven::container::redis (
  $net     = 'web',
  $depends = undef,
) {
  docker::run { $title:
    image   => 'redis',
    net     => $net,
    depends => $depends,
  }
}
