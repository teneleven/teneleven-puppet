define teneleven::fpm::extension ($extension = $title) {
  class { "php::extension::$extension":
    ensure => latest
  }
}
