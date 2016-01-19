class teneleven::nginx (
  $vhosts   = {},
  $user     = $teneleven::params::web_user,
  $wildcard = undef,

  /* only used if $::is_container is true */
  $service_command = 'nginx -g "daemon off;"',
) inherits teneleven::params {
  contain teneleven

  create_resources('teneleven::nginx::vhost', $vhosts, {})

  if ($wildcard) {
    create_resources('teneleven::nginx::wildcard', { 'wildcard' => $wildcard })
  }

  if ($::is_container) {
    /* todo this shouldn't be a hard stop every time */
    class { '::nginx':
      service_ensure => stopped
    }

    supervisord::program { 'nginx':
      command     => $service_command,
      autorestart => true,
    } ~> exec { 'load-nginx':
      command => "${::teneleven::supervisorctl_command} reload"
    }
  } else {
    contain ::nginx
  }
}
