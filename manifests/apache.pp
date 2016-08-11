class teneleven::apache (
  $vhosts   = {},
  $modules  = {},
  $config   = {},

  $port            = 80,
  $ssl_port        = 443,
  $ssl             = false,
  $serve_php_files = true,
  $default_vhost   = true,

  /* only used if $::is_container is true */
  $service_command = 'apache2ctl -DFOREGROUND',
) inherits teneleven::params {

  $web_user = $config['user'] ? {
    default => $config['user'],
    undef   => $teneleven::params::web_user
  }

  $web_group = $config['group'] ? {
    default => $config['group'],
    undef   => $teneleven::params::web_group
  }

  $default_vhost_options = {
    docroot_owner => $web_user,
    docroot_group => $web_group
  }

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

    include apache::params

    /* this ensures correct permissions on fastcgi_lib_path */
    file { $::apache::params::fastcgi_lib_path:
      ensure => directory,
      owner  => $web_user,
      group  => $web_group,
      before => File['fastcgi.conf']
    }
  }

  apache::listen { "${port}": }

  if ($ssl) {
    apache::listen { "${ssl_port}": }
  }

  if ($::is_container) {
    $default_apache_options = {
      service_ensure => stopped,
      manage_user    => false,
      manage_group   => false,
      default_vhost  => $default_vhost,
      user           => $web_user,
      group          => $web_group
    }

    supervisord::program { 'apache':
      command     => $service_command,
      autorestart => true,
      killasgroup => true,
      stopasgroup => true,
    }
  } else {
    $default_apache_options = {
      default_vhost  => $default_vhost,
      user           => $web_user,
      group          => $web_group
    }
  }

  create_resources('class', { '::apache' => merge(
    $default_apache_options,
    $config
  )})

  contain '::apache'

}
