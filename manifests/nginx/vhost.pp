/**
 * Vhost helper with defaults for symfony site.
 */
define teneleven::nginx::vhost (
  /* unique site name */
  $site                = $title,

  /* string or array of strings */
  $hosts               = 'test.example.com',

  /* default:            $web_root/$site/web */
  $path                = "${teneleven::params::web_root}/${title}/web",

  $serve_php_files     = false, /* mostly useful for simple php apps */
  $app                 = undef, /* send all undefined requests to this script (also sets index) */
  $proxy               = undef, /* proxy all undefined requests to this uri/upstream */

  $location_cfg_append = undef,
  $locations           = {},

  $ssl                 = false,
  $ssl_cert            = undef,
  $ssl_key             = undef,

  /* fcgi socket or HOST:PORT */
  $fcgi_host           = "unix:///${teneleven::params::web_root}/$title/app.sock",
  /* location of FCGI PHP scripts */
  $fcgi_app_root       = "${teneleven::params::app_root}",
) {
  include params

  if ($app) {
    $index_files = [$app]
    $location_cfg = merge({
      'try_files' => "\$uri /${app}\$is_args\$args"
    }, $location_cfg_append)
  } else {
    if ($serve_php_files) {
      $index_files = ['index.html', 'index.htm', 'index.php']
    } else {
      $index_files = ['index.html', 'index.htm']
    }

    $location_cfg = $location_cfg_append
  }

  ::nginx::resource::vhost { $site:
    ensure              => present,
    index_files         => $index_files,
    server_name         => any2array($hosts),
    www_root            => $path,
    location_cfg_append => $location_cfg,
    ssl                 => $ssl,
    ssl_cert            => $ssl_cert,
    ssl_key             => $ssl_key,
    proxy               => $proxy,
  }

  if ($app) {
    ::nginx::resource::location { "${name}_app":
      ensure          => present,
      vhost           => $site,
      www_root        => $path,
      location        => "~ ^/${app}(/|\$)",
      priority        => 401, /* ensure this rule gets hit before DENY rule below */
      fastcgi         => $fcgi_host,
      fastcgi_param   => {
        'SCRIPT_FILENAME' => "${fcgi_app_root}/\$fastcgi_script_name"
      },
    }
  }

  if ($serve_php_files) {
    /* handle *.php files */
    ::nginx::resource::location { "${site}_php":
      ensure          => present,
      vhost           => $site,
      www_root        => $path,
      location        => '~ [^/]\.php(/|$)',
      fastcgi         => $fcgi_host,
      fastcgi_param   => {
        'SCRIPT_FILENAME' => "${fcgi_app_root}/\$fastcgi_script_name"
      },

      /* don't allow access if file doesn't exist */
      raw_prepend     => 'if (!-f $document_root$fastcgi_script_name) { return 404; }',
    }
  } else {
    /* block access to *.php files */
    ::nginx::resource::location { "${site}_php":
      ensure          => present,
      vhost           => $site,
      www_root        => $path,
      priority        => 600,
      location        => '~ [^/]\.php(/|$)',
      location_cfg_prepend => {
        'deny' => 'all',
        'access_log' => 'off',
        'log_not_found' => 'off',
      }
    }
  }

  create_resources('nginx::resource::location', $locations, {})
}
