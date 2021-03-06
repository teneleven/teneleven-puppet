define teneleven::docker::compose (
  $app_name = $title,
  $app_type = undef,
  $env      = []
) {

  include ::teneleven::docker
  include ::teneleven::docker::image

  $compose_fallback_dir = $teneleven::docker::compose_fallback_dir ? {
    undef   => "${teneleven::docker::compose_dir}",
    default => "${teneleven::docker::compose_fallback_dir}",
  }

  $compose_app_name_path = "${teneleven::docker::compose_dir}/${app_name}/${teneleven::docker::compose_file}"
  $compose_app_type_path = "${teneleven::docker::compose_dir}/${app_type}/${teneleven::docker::compose_file}"
  $compose_app_type_fallback_path = "${compose_fallback_dir}/${app_type}/${teneleven::docker::compose_file}"
  $compose_fallback_path = "${compose_fallback_dir}/${teneleven::docker::compose_default}"

  $compose_environment = $env ? {
    undef => ["COMPOSE_PROJECT_NAME=${app_name}", "COMPOSE_APP_TYPE=${app_type}"],
    default => concat(["COMPOSE_PROJECT_NAME=${app_name}"], $env)
  }

  /* compose app_name */
  exec { "compose-name-${app_name}":
    command     => "docker-compose -f ${compose_app_name_path} up -d",
    provider    => 'shell',
    environment => $compose_environment,
    onlyif      => "/usr/bin/test -e ${compose_app_name_path}",
    require     => Class[teneleven::docker::image]
  }

  if $app_type {
    /* compose app_type */
    exec { "compose-type-${app_name}-${app_type}":
      command     => "docker-compose -f ${compose_app_type_path} up -d",
      provider    => 'shell',
      environment => $compose_environment,
      unless      => "/usr/bin/test -e ${compose_app_name_path}",
      onlyif      => "/usr/bin/test -e ${compose_app_type_path}",
      require     => Class[teneleven::docker::image]
    }

    /* compose app_type fallback */
    exec { "compose-type-fallback-${app_name}-${app_type}":
      command     => "docker-compose -f ${compose_app_type_path} up -d",
      provider    => 'shell',
      environment => $compose_environment,
      unless      => "/usr/bin/test -e ${compose_app_name_path} || /usr/bin/test -e ${compose_app_type_path}",
      onlyif      => "/usr/bin/test -e ${compose_app_type_fallback_path}",
      require     => Class[teneleven::docker::image]
    }
  }

  /* compose fallback (if app_name doesn't exist) */
  exec { "compose-default-${app_name}":
    command     => "docker-compose -f ${compose_fallback_path} up -d",
    provider    => 'shell',
    environment => $compose_environment,
    unless      => "/usr/bin/test -e ${compose_app_name_path} || /usr/bin/test -e ${compose_app_type_path} || /usr/bin/test -e ${compose_app_type_fallback_path}",
    require     => Class[teneleven::docker::image]
  }

}
