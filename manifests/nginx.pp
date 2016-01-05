class teneleven::nginx (
  $vhosts   = {},
  $user     = $params::web_user,
) inherits params {
  contain teneleven

  create_resources('teneleven::nginx::vhost', $vhosts, {})

  /* ensure no service management for docker */
  class { '::nginx':
    service_ensure => 'stopped',
    daemon_user    => $user,
  }

  supervisord::program { 'nginx':
    command => 'nginx -g "daemon off;"'
  }
}
