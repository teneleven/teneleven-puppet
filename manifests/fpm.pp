class teneleven::fpm (
  $extensions = {},
  $settings   = {},

  /* PHP.ini config */
  $config     = {},

  $dev        = true,

  $user       = $teneleven::params::web_user,
  $group      = $teneleven::params::web_group,

  $fcgi_listen   = "${teneleven::params::web_root}/app.sock",
  $fcgi_web_root = $teneleven::params::web_root, /* signifies main /var/www mount */
  $fcgi_app_root = $teneleven::params::app_root, /* signifies web accessible /var/www/web */

  /* if set, manage via supervisord */
  $service_command = 'php5-fpm -F',
) inherits teneleven::params {

  contain teneleven

  teneleven::fpm::extension { $extensions: }

  contain php::fpm::params
  contain php::fpm::package

  if ($service_command) {
    class { php::fpm::service:
      enable => false,
      ensure => 'stopped',
    }

    supervisord::program { 'fpm':
      command => $service_command
    }
  }

  php::fpm::config { 'php-fpm':
    file    => $php::fpm::params::inifile,
    config  => $settings
  }

  php::fpm::pool { 'www':
    listen       => $fcgi_listen,
    chdir        => $fcgi_app_root,
    user         => $user,
    group        => $group,
    listen_owner => $user,
    listen_group => $group,
  }

  if ($dev) {
    contain teneleven::fpm::debug
  }

  $config.each |$conf, $val| {
    php::fpm::config { $conf:
      setting => $conf,
      value   => $val,
      require => Package['php5-fpm'],
    }
  }
}
