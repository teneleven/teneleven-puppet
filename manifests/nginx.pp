class teneleven::nginx (
  $vhosts   = {},
  $user     = $params::web_user,
  $wildcard = undef,

  /* if set, manage via supervisord */
  $service_command = 'nginx -g "daemon off;"',
) inherits params {
  contain teneleven

  create_resources('teneleven::nginx::vhost', $vhosts, {})

  if ($wildcard) {
    create_resources('teneleven::nginx::wildcard', { 'wildcard' => $wildcard })
  }

  if ($service_command) {
    class { '::nginx':
      service_ensure => stopped
    }

    supervisord::program { 'nginx':
      command     => $service_command,
      autorestart => true,
      autostart   => true,
    }
  } else {
    contain ::nginx
  }
}
