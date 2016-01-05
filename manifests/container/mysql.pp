class teneleven::container::mysql {
  docker::run { "mysql":
    image   => "mysql",
    volumes => [
      "${volume_dir}/mysql/data:/var/lib/mysql",
      "${volume_dir}/mysql/socket:/var/run/mysqld"
    ],
    env     => ["MYSQL_ROOT_PASSWORD=123"],
    net     => "web"
  }
}
