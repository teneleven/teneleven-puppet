class teneleven::docker (
  $install    = false,
  $images     = [],
  $run        = [],
  $provision  = [],
  $containers = {},

  $compose         = [],
  $compose_default = 'default.yml',
  $compose_file    = 'docker-compose.yml',
  $compose_dir     = 'docker-compose'
) {
  if ($install) {
    if ($::is_container) {
      class { '::docker':
        service_enable => false,
        service_state  => undef,
      }
    }

    contain '::docker'
  }

  if (!empty($images)) {
    $images.each |$name| {
      $options = $containers[$name] ? {
        undef   => {},
        default => $containers[$name]
      }

      create_resources('docker::image', { $name => $options })
    }
  }

  if (!empty($run)) {
    $run.each |$name| {
      $options = $containers[$name] ? {
        undef   => {},
        default => $containers[$name]
      }

      create_resources('teneleven::container::run', { $name => { options => $options } })
    }
  }

  if (!empty($provision)) {
    $provision.each |$name| {
      /* todo make this configurable */
      $default_options = {
        volumes      => ["${::volume_dir}/www/${name}:/var/www"],
        volumes_from => ['mysql']
      }

      $options = $containers[$name] ? {
        undef   => $default_options,
        default => merge($default_options, $containers[$name])
      }

      create_resources('teneleven::container::provision', { $name => { run_options => $options } })
    }
  }

  if (!empty($compose)) {
    $compose.each |$name, $app_type| {
      $compose_app_path = "${compose_dir}/${name}/${compose_file}"
      $compose_default_path = "${compose_dir}/${compose_default}"
      $compose_test = "/usr/bin/test -e ${compose_app_path}"

      /* compose app NAME */
      exec { "compose-${name}":
        command     => "docker-compose -f ${compose_app_path} up -d",
        provider    => 'shell',
        environment => ["COMPOSE_PROJECT_NAME=${name}", "COMPOSE_APP_TYPE=${app_type}"],
        onlyif      => $compose_test
      }

      /* compose fallback (if app NAME doesn't exist) */
      exec { "compose-default-${name}":
        command     => "docker-compose -f ${compose_default_path} up -d",
        provider    => 'shell',
        environment => ["COMPOSE_PROJECT_NAME=${name}", "COMPOSE_APP_TYPE=${app_type}"],
        unless      => $compose_test
      }
    }
  }
}
