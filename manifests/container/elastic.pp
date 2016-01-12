define teneleven::container::elastic (
  $net        = 'web',
  $depends    = undef,
) {
  docker::run { $title:
    image   => 'elasticsearch',
    volumes => [
      "${::volume_dir}/elastic/data:/usr/share/elasticsearch/data",
      "${::volume_dir}/elastic/config:/usr/share/elasticsearch/config"
    ],
    net     => $net,
    depends => $depends,
  }
}
