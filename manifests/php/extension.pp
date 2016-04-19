define teneleven::php::extension ($extension = $title) {
  class { "php::extension::$extension":
    ensure => latest
  }
}
