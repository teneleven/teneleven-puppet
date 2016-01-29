class teneleven::apache (
  $vhosts   = {},
  $modules  = {},
  $user     = $teneleven::params::web_user,

  $serve_php_files = true,

  /* only used if $::is_container is true */
  $service_command = 'apache2',
) inherits teneleven::params {

  $vhosts.each |$name, $options| {
    create_resources('teneleven::apache::vhost', { $name => {
      options => $options
    }})
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

  apache::listen { '80': }

  if ($::is_container) {
    class { '::apache':
      service_ensure => stopped,
      manage_user    => false,
      manage_group   => false,
    }

    supervisord::program { 'apache':
      command     => $service_command,
      autorestart => true,
    } -> exec { 'load-apache':
      command => "${::teneleven::supervisorctl_command} reload"
    }
  }

  contain '::apache'

}
