/**
 * Vhost helper with defaults for symfony site.
 */
define teneleven::nginx::vhost (
  /* unique site name */
  $site                = $title,

  /* string or array of strings */
  $hosts               = 'test.example.com',

  /* nginx listen options */
  $listen_options      = undef,

  /* default:            $web_root/$site/web */
  $path                = "${teneleven::params::web_root}/${title}/${teneleven::params::web_suffix}",

  $serve_php_files     = false, /* mostly useful for simple php apps */
  $app                 = undef, /* proxy all 404'ed requests to this php app */
  $proxy               = undef, /* proxy all undefined requests to this uri/upstream */
  $resolver            = [],    /* proxy resolver */

  /* fcgi directives, see fcgi.pp */
  $fcgi_host           = '127.0.0.1:9000',
  $fcgi_socket         = undef,
  $fcgi_app_root       = $teneleven::nginx::app_root,
  $additional_apps     = {}, /* additional fcgi definitions */

  $location_cfg_append = undef,
  $locations           = {},

  $ssl                 = false,
  $ssl_cert            = undef,
  $ssl_key             = undef,
) {
  if ($app) {
    $index_files = any2array($app)
    $try_files = $index_files.map |$file| {
      "/${file}\$is_args\$args"
    }
    $location_cfg = merge({
      'try_files' => join(concat(
        ['$uri'],
        $try_files
      ), ' ')
    }, $location_cfg_append)
  } else {
    if ($serve_php_files) {
      $index_files = ['index.html', 'index.htm', 'index.php']
    } else {
      $index_files = ['index.html', 'index.htm']
    }

    $location_cfg = $location_cfg_append
  }

  if ($fcgi_socket) {
    $real_fcgi_host = "unix:///${fcgi_socket}"
  } else {
    $real_fcgi_host = $fcgi_host
  }

  ::nginx::resource::vhost { $site:
    ensure              => present,
    index_files         => $index_files,
    listen_options      => $listen_options,
    server_name         => any2array($hosts),
    www_root            => $proxy ? {
      undef   => $path,
      default => undef
    },
    location_cfg_append => $location_cfg,
    ssl                 => $ssl,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    proxy               => $proxy,
    proxy_set_header    => $proxy ? {
      undef   => [],
      default => ['Host $host', 'X-Forwarded-For $remote_addr']
    },
    resolver            => $resolver,
  }

  if ($app) {
    teneleven::nginx::fcgi { "${site}_app":
      site     => $site,
      path     => $path,
      host     => $real_fcgi_host,
      app      => $app,
      app_root => $fcgi_app_root,
    }
  }

  if ($serve_php_files) {
    /* handle *.php files */
    teneleven::nginx::fcgi { "${site}_php":
      site     => $site,
      path     => $path,
      location => '~ [^/]\.php(/|$)',
      host     => $real_fcgi_host,
      app_root => $fcgi_app_root,

      custom_cfg => {
        'fastcgi_split_path_info' => '^(.*.php)(.*)$',
        /* fixes nginx path_info bug: https://forum.nginx.org/read.php?2,238825,238860 */
        'fastcgi_param PATH_INFO' => '$path_info',
        'set $path_info' => '$fastcgi_path_info',
      },

      /* don't allow access if file doesn't exist */
      custom_raw => 'if (!-f $document_root$fastcgi_script_name) { return 404; }',
    }
  } else {
    if (!$proxy) {
      /* block access to *.php files */
      teneleven::nginx::fcgi { "${site}_php":
        site     => $site,
        path     => $path,
        host     => $real_fcgi_host,
        app_root => $fcgi_app_root,
        priority => 600,
        location => '~ [^/]\.php(/|$)',

        custom_cfg => {
          'deny' => 'all',
          'access_log' => 'off',
          'log_not_found' => 'off',
        }
      }
    }
  }

  create_resources('nginx::resource::location', $locations, {})
  create_resources('teneleven::nginx::fcgi',    $additional_apps, {})
}
