define teneleven::provision::docker (
  $app_name  = $title,
  $container = $title,

  $exec_options     = {},
  $commit_container = true
) {

  include ::teneleven::docker
  include ::teneleven::docker::image
  include ::teneleven::params

  /* provision */
  teneleven::docker::exec { "provision-${app_name}":
    container => $container,
    options   => merge({
      command => $::teneleven::params::provision_cmd
    }, $exec_options)
  } -> teneleven::docker::exec { "reload-${app_name}":
    container => $container,
    options   => {
      command => $::teneleven::params::reload_cmd
    }
  }

  if ($commit_container) {
    Teneleven::Docker::Exec["provision-${app_name}"] -> teneleven::docker::commit { $container:
      tag => "${::teneleven::params::docker_prefix}:${app_name}"
    }
  }

}
