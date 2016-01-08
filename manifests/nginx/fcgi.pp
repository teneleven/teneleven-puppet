define teneleven::nginx::fcgi (
  $site = undef, /* vhost */

  $path = "${teneleven::params::web_root}/${title}/${teneleven::params::web_suffix}",

  /* fcgi socket or HOST:PORT */
  $host = "unix:///${teneleven::params::web_root}/\$sname/app.sock",
  /* fcgi app root in the fcgi container (e.g. /var/www or /app) */
  $app_root = $teneleven::params::app_root,

  $app      = undef,
  $location = undef,
  $priority = 401,

  $custom_cfg = undef, /* custom nginx location directive(s) */
  $custom_raw = undef, /* custom, raw, nginx location directive(s) */
) {
  $fcgi_script = $app ? {
    undef => '$fastcgi_script_name',
    default => $app
  }

  ::nginx::resource::location { $title:
    ensure          => present,
    vhost           => $site,
    www_root        => $path,
    location        => $location ? {
      undef   => "~ ^/${app}(/|\$)",
      default => $location
    },
    fastcgi         => $host,
    fastcgi_param   => {
      'SCRIPT_FILENAME' => "${app_root}/${fcgi_script}"
    },
    priority        => $priority,

    location_cfg_prepend => $custom_cfg,
    raw_prepend          => $custom_raw,
  }
}
