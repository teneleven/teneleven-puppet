/* represents a pre-configured wildcard vhost - proxies from *.docker to hostname */
define teneleven::nginx::wildcard (
  $host_suffix         = '\\.docker', /* eg .com or .net */
  $path_suffix         = $teneleven::params::web_suffix,

  $serve_php_files     = false, /* mostly useful for simple php apps */
  $app                 = undef, /* send all undefined requests to this script (also sets index) */
  $proxy               = undef, /* proxy all undefined requests to this uri/upstream */
  $resolver            = [],    /* proxy resolver */

  /* sets up dnsmasq and sets wildcard resolver */
  $dnsmasq             = undef,

  /* fcgi directives, see fcgi.pp */
  $additional_apps     = {}, /* additional fcgi definitions */
  $fcgi_host           = "unix:///${teneleven::params::web_root}/\$sname/app.sock",
  $fcgi_app_root       = $teneleven::nginx::app_root,

  $location_cfg_append = undef,
  $locations           = {},

  $ssl                 = false,
  $ssl_cert            = undef,
  $ssl_key             = undef,
) {

  /* setup dnsmasq resolver */
  if ($use_dnsmasq) {
    package { 'dnsmasq':
      ensure => present
    }

    supervisord::program { 'dnsmasq':
      command     => 'dnsmasq -u root -k',
      autorestart => true,
    }
  }

  teneleven::nginx::vhost { $title:
    hosts               => "~^(www\\.)?(?<sname>.+?)${host_suffix}\$",
    path                => "${teneleven::params::web_root}/\$sname/${path_suffix}",

    serve_php_files     => $serve_php_files,
    app                 => $app,
    proxy               => $proxy,
    resolver            => any2array($resolver),

    location_cfg_append => $location_cfg_append,
    locations           => $locations,

    ssl                 => $ssl,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,

    /* fcgi socket or HOST:PORT */
    fcgi_host           => $fcgi_host,
    /* location of FCGI PHP scripts */
    fcgi_app_root       => $fcgi_app_root,
  }

  create_resources('nginx::resource::location', $locations, {})
  create_resources('teneleven::nginx::fcgi',    $additional_apps, {})

}
