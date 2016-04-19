class teneleven::apache (
  $vhosts   = {},
  $modules  = {},
  $user     = $teneleven::params::web_user,

  $port            = 80,
  $ssl_port        = 443,
  $ssl             = false,
  $serve_php_files = true,
  $default_vhost   = true,

  $default_vhost_options = {
    docroot_owner => 'www-data',
    docroot_group => 'www-data'
  },

  /* only used if $::is_container is true */
  $service_command = 'apache2ctl -DFOREGROUND',
) inherits teneleven::params {

  $vhosts.each |$name, $options| {
    create_resources('::apache::vhost', { $name => merge(
      $default_vhost_options,
      $options,
      { port => $port }
    ) })

    if ($ssl) {
      create_resources('::apache::vhost', { "${name}_ssl" => merge(
        $default_vhost_options,
        $options,
        { port => $ssl_port }
      ) })
    }
  }

  if $modules.is_a(Array) {
    $modules.each |$mod| {
      create_resources('::apache::mod', { $mod => {} })
    }
  } else {
    create_resources('::apache::mod', $modules)
  }

  if ($serve_php_files) {
    class { 'apache::mod::actions': }

    apache::fastcgi::server { 'php':
      host       => '127.0.0.1:9000',
      timeout    => 30,
      flush      => false,
      faux_path  => '/var/run/php.fcgi',
      fcgi_alias => '/php.fcgi',
      file_type  => 'application/x-httpd-php'
    }
  }

  apache::listen { "${port}": }

  if ($ssl) {
    apache::listen { "${ssl_port}": }
  }

  if ($::is_container) {
    class { '::apache':
      service_ensure => stopped,
      manage_user    => false,
      manage_group   => false,
      default_vhost  => $default_vhost
    }

    supervisord::program { 'apache':
      command     => $service_command,
      autorestart => true,
      killasgroup => true,
      stopasgroup => true,
    }
  } else {
    class { '::apache':
      default_vhost  => $default_vhost
    }
  }

  contain '::apache'

}
