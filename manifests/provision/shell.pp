define teneleven::provision::shell (
  $app_name = $title,
  $env = []
) {

  include ::teneleven::params

  exec { "provision-${app_name}":
    command => $::teneleven::params::provision_cmd,
    environment => $env,
    path => ['/bin', '/usr/bin']
  }

}
