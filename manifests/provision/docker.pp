define teneleven::provision::docker (
  $app_name = $title,
  $app_type,
  $app_hosts,

  $run_options = {}
) {

  include ::teneleven::docker
  include ::teneleven::docker::image

  Class[::teneleven::docker::image] -> Class[::teneleven::docker::run] -> Class[::teneleven::docker::commit]

  if (is_array($app_hosts)) {
    $app_hosts_str = join($app_hosts, ',')
  } elsif (is_string($app_hosts)) {
    $app_hosts_str = $app_hosts
  } else {
    fail('Invalid app_hosts type passed to teneleven::provision::docker_compose')
  }

  teneleven::docker::run { $app_name:
    options => merge({
      command => 'sh -c "/provision.sh; supervisord -n"',
      env     => [
        "FACTER_project_name=${app_name}",
        "FACTER_app_type=${app_type}",
        "FACTER_app_hosts=${app_hosts_str}"
      ]
    }, $run_options),
  }

  /* FIXME see docker_compose.pp */
  /* teneleven::docker::commit { $title: } */

}
