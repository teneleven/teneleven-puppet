class teneleven::php (
  $extensions = {},
  $settings   = {},

  /* PHP.ini config */
  $config     = {},

  $composer   = false,
  $dev        = true,

  $user       = $teneleven::params::web_user,
  $group      = $teneleven::params::web_group,

  $listen     = '127.0.0.1:9000',

  $path       = $teneleven::params::app_root, /* signifies web accessible /var/www/web */

  /* only used if $::is_container is true */
  $service_command = 'php5-fpm -F',
) inherits teneleven::params {

  teneleven::php::extension { $extensions: }

  contain php::cli

  if ($composer) {
    $composer_settings = is_hash($composer) ? {
      true  => $composer,
      false => {}
    }

    create_resources('class', { php::composer => $composer_settings })
  }

  if ($::is_container) {
    $service_enabled = false
    $service_ensure  = 'stopped'

    supervisord::program { 'fpm':
      command     => $service_command,
      autorestart => true,
    }
  } else {
    $service_enabled = true
    $service_ensure  = 'running'
  }

  class { php::fpm:
    service_enable => $service_enabled,
    service_ensure => $service_ensure,
    settings       => $settings
  }

  php::fpm::pool { 'www':
    listen       => $listen,
    chdir        => $path,
    user         => $user,
    group        => $group,
    listen_owner => $user,
    listen_group => $group,
  }

  if ($dev) {
    contain teneleven::php::debug
  }

  $config.each |$conf, $val| {
    php::fpm::config { $conf:
      setting => $conf,
      value   => $val,
      require => Package['php5-fpm'],
    }
  }

}
