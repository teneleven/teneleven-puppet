define teneleven::provision::docker_compose (
  $app_name = $title,
  $container_name = undef /* by default uses $app_name + $teneleven::params::docker_compose_suffix */
) {

  include ::teneleven::docker
  include ::teneleven::docker::image
  include ::teneleven::params

  teneleven::provision::docker { $app_name:
    container => $container_name ? {
      undef   => "${app_name}${::teneleven::params::docker_compose_suffix}",
      default => $container_name
    }
  }

}
