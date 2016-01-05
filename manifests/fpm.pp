class teneleven::fpm (
  $extensions = {},
  $settings   = {},
  $dev        = true,

  $user       = $params::web_user,

  $fcgi_web_root = $params::web_root, /* signifies main /var/www mount */
  $fcgi_app_root = $params::app_root, /* signifies web accessible /var/www/web */
  $fcgi_port     = $params::app_port,
) inherits params {

  contain teneleven

  teneleven::fpm::extension { $extensions: }

  /* service management */
  supervisord::program { 'fpm':
    command => 'php5-fpm -F'
  }

  /** Generic FPM configuration for usage across docker network **/

  include php::fpm::params
  include php::fpm::package

  class { php::fpm::service:
    enable => false,
    ensure => 'stopped',
  }

  php::fpm::config { 'php-fpm':
    file    => $php::fpm::params::inifile,
    config  => $settings
  }

  php::fpm::pool { 'www':
    listen => "${fcgi_web_root}/app.sock",
    user   => $user,
    chdir  => $fcgi_app_root,
  }

  if ($dev) {
    php::fpm::config { 'display_errors':
      setting => 'display_errors',
      value   => 'On',
      require => Package['php5-fpm'],
    }
  }

}
