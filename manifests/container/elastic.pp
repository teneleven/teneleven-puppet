define teneleven::container::elastic (
  $volume_dir = '/volumes',
  $net        = 'web'
) {
  docker::run { $title:
    image   => 'elasticsearch',
    volumes => [
      "${volume_dir}/elastic/data:/usr/share/elasticsearch/data",
      "${volume_dir}/elastic/config:/usr/share/elasticsearch/config"
    ],
    net     => $net
  }
}
