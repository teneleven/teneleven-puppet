define teneleven::provision::shell (
  $app_name = $title,
  $app_type,
  $app_hosts
) {

  if (is_array($app_hosts)) {
    $app_hosts_str = join($app_hosts, ',')
  } elsif (is_string($app_hosts)) {
    $app_hosts_str = $app_hosts
  } else {
    fail('Invalid app_hosts type passed to teneleven::provision::docker_compose')
  }

  exec { "provision-${app_name}":
    command => 'sh -c "./provision.sh; supervisord -n"',
    environment => ["FACTER_project_name=${app_name}", "FACTER_app_type=${app_type}", "FACTER_app_hosts=${app_hosts_str}"],
    path => ['/bin', '/usr/bin']
  }

}
