class teneleven::container::elastic {
  docker::run { "elastic":
    image   => "elasticsearch",
    volumes => [
      "${volume_dir}/elastic/data:/usr/share/elasticsearch/data",
      "${volume_dir}/elastic/config:/usr/share/elasticsearch/config"
    ],
    ports   => ["9200:9200", "9300:9300"],
    expose  => ["9200", "9300"],
    net     => "web"
  }
}
