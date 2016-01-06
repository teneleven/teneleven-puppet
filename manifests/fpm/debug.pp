/* enables dev helpers for PHP - for now, just error reporting & xdebug */
class teneleven::fpm::debug (
  $display_errors = true,
  $enable_xdebug  = true,
) {
  if ($display_errors) {
    php::fpm::config { 'display_errors':
      setting => 'display_errors',
      value   => 'On',
      require => Package['php5-fpm'],
    }
  }

  if ($enable_xdebug) {
    contain php::extension::xdebug

    teneleven::fpm::xdebug {
      ['xdebug.remote_enable', 'xdebug.remote_connect_back']:
        value => '1'
    }

    teneleven::fpm::xdebug {
      'xdebug.max_nesting_level':
        value => '10000'
    }
  }
}
