define teneleven::container::redis (
  $net = 'web'
) {
  docker::run { $title:
    image => 'redis',
    net   => $net
  }
}
