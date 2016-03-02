class teneleven::docker (
  $install    = false,
  $images     = [],
  $run        = [],
  $provision  = [],
  $compose    = [],
  $containers = {}
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
    $compose.each |$name, $compose_file| {
      /* simple exec for docker-compose */
      exec { "compose-${name}":
        command     => "docker-compose -f ${compose_file} up &",
        provider    => 'shell',
        environment => ["COMPOSE_PROJECT_NAME=${name}"]
      }

      /* FIXME not working since not setting env variable */
      /* docker_compose { $compose_file: */
      /*   ensure  => present, */
      /*   options => "-p ${name}" */
      /* } */
    }
  }
}
