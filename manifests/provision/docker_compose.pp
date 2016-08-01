define teneleven::provision::docker_compose (
  $app_name = $title,
  $app_type,
  $app_hosts
) {

  include ::teneleven::docker
  include ::teneleven::docker::image

  if (is_array($app_hosts)) {
    $app_hosts_str = join($app_hosts, ',')
  } elsif (is_string($app_hosts)) {
    $app_hosts_str = $app_hosts
  } else {
    fail('Invalid app_hosts type passed to teneleven::provision::docker_compose')
  }

  teneleven::docker::compose { $app_name:
    app_type => $app_type,
    env      => ["COMPOSE_APP_TYPE=${app_type}", "COMPOSE_APP_HOSTS=${app_hosts_str}"]
  }

  /* FIXME this doesn't quite work because docker-compose exits in main thread immediately */
  /* teneleven::docker::commit { $title: } */

}
