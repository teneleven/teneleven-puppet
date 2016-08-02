class teneleven::params (
  $web_root   = "/var/www",
  $web_suffix = 'web',
  $app_root   = "/var/www", /* fcgi php root path */
  $app_port   = 9000,       /* fcgi port */

  $docker_prefix         = 'local',  /* for use to commit container after provisioning */
  $docker_compose_suffix = '_web_1', /* for use during provisioning docker-compose container */

  $docker_cmd    = 'supervisord -n', /* use this in docker-compose.yml maybe using ERB template */
  $provision_cmd = 'sh /provision.sh',
  $reload_cmd    = 'supervisorctl reload',

  $web_user   = 'www-data',
  $web_group  = 'www-data',
  $web_uid    = 1000,
  $web_gid    = 1000,

  $puppet_mount   = '/puppet',   /* destination mount on the container */

  $proxy_resolver = '127.0.0.1', /* this sets up dnsamsq for nginx - set to undef to disable */
) {}
