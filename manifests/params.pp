class teneleven::params (
  $web_root   = "/var/www",
  $web_suffix = 'web',
  $app_root   = "/var/www", /* fcgi php root path */
  $app_port   = 9000,       /* fcgi port */

  $web_user   = 'www-data',
  $web_group  = 'www-data',
  $web_uid    = 1000,
  $web_gid    = 1000,

  $proxy_resolver = '127.0.0.1', /* this sets up dnsamsq for nginx - set to undef to disable */
) {}
