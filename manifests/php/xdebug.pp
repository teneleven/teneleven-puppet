/* xdebug specific php setting(s) */
define teneleven::php::xdebug (
  $setting = $title,
  $value   = undef,
) {
  php::fpm::config { $setting:
    setting => $setting,
    value   => $value,
    section => 'xdebug',
    require => Package['php5-fpm'],
  }

  php::cli::config { "${setting}-cli":
    setting => $setting,
    value   => $value,
    section => 'xdebug',
    require => Package['php5-cli'],
  }
}
