class teneleven::fpm (
  $extensions = {},
  $settings   = {},
  $dev        = true,

  $user       = $params::web_user,
  $group      = $params::web_group,

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

  contain php::fpm::params
  contain php::fpm::package

  class { php::fpm::service:
    enable => false,
    ensure => 'stopped',
  }

  php::fpm::config { 'php-fpm':
    file    => $php::fpm::params::inifile,
    config  => $settings
  }

  php::fpm::pool { 'www':
    listen       => "${fcgi_web_root}/app.sock",
    chdir        => $fcgi_app_root,
    user         => $user,
    group        => $group,
    listen_owner => $user,
    listen_group => $group,
  }

  if ($dev) {
    contain teneleven::fpm::debug
  }

}
