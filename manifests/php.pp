class teneleven::php (
  $extensions = {},
  $settings   = {},

  /* PHP.ini config */
  $config     = {},

  $dev        = true,

  $user       = $teneleven::params::web_user,
  $group      = $teneleven::params::web_group,

  $listen     = '127.0.0.1:9000',

  $path       = $teneleven::params::app_root, /* signifies web accessible /var/www/web */

  /* only used if $::is_container is true */
  $service_command = 'php5-fpm -F',
) inherits teneleven::params {

  teneleven::php::extension { $extensions: }

  contain php::fpm::params
  contain php::fpm::package
  contain php::cli

  if ($::is_container) {
    class { php::fpm::service:
      enable => false,
      ensure => 'stopped',
    }

    supervisord::program { 'fpm':
      command     => $service_command,
      autorestart => true,
    }
  } else {
    contain ::php::fpm::service
  }

  php::fpm::config { 'php-fpm':
    file    => $php::fpm::params::inifile,
    config  => $settings
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
