class teneleven::nginx (
  $vhosts   = {},
  $user     = $params::web_user,

  /* if set, manage via supervisord */
  $service_command = 'nginx -g "daemon off;"',
) inherits params {
  contain teneleven
  contain ::nginx

  create_resources('teneleven::nginx::vhost', $vhosts, {})

  if ($service_command) {
    supervisord::program { 'nginx':
      command     => $service_command
    }
  }
}
