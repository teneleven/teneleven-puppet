class teneleven::mysql (
  $root_password   = '123',
  $databases       = {},

  $default_options = {}
) {

  $databases.each |$name, $database| {
    create_resources('::mysql::db', { $name => merge(
      $default_options,
      $database
    ) })
  }

  class { '::mysql::server':
    root_password => $root_password
  }

  contain '::mysql::server'

}
