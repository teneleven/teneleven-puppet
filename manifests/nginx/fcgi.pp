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
  $apps = $app ? {
    default => any2array($app),
    undef   => ['$fastcgi_script_name']
  }

  $apps.each |$app| {
    ::nginx::resource::location { "${title}_${app}":
      ensure          => present,
      vhost           => $site,
      www_root        => $path,
      location        => $location ? {
        default => $location,
        undef   => "~ ^/${app}(/|\$)"
      },
      fastcgi         => $host,
      fastcgi_param   => {
        'SCRIPT_FILENAME' => "${app_root}/${app}"
      },
      priority        => $priority,

      location_cfg_prepend => $custom_cfg,
      raw_prepend          => $custom_raw,
    }
  }
}
