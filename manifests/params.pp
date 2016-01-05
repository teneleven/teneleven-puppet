class teneleven::params (
  $web_root     = "/var/www",
  $app_root     = "/var/www/web", /* fcgi php root path */
  $app_port     = 9000,           /* fcgi port */

  $web_user  = 'www-data',
  $web_group = 'www-data',
  $web_uid   = 1000,
  $web_gid   = 1000,
) {}
