define teneleven::container::mysql (
  $volume_dir = '/volumes',
  $root_pass  = '123',
  $net        = 'web',
  $depends    = undef,
) {
  docker::run { $title:
    image   => 'mysql',
    volumes => [
      "${volume_dir}/mysql/data:/var/lib/mysql",
      "${volume_dir}/mysql/socket:/var/run/mysqld"
    ],
    env     => ["MYSQL_ROOT_PASSWORD=${root_pass}"],
    net     => $net,
    depends => $depends,
  }
}
