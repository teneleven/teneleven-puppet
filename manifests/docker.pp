class teneleven::docker (
  $install    = false,
  $images     = [],
  $run        = [],
  $provision  = [],
  $containers = {},

  $compose              = [],
  $compose_default      = 'default.yml',
  $compose_file         = 'docker-compose.yml',
  $compose_dir          = 'docker-compose',
  $compose_fallback_dir = undef
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

      create_resources('teneleven::docker::run', { $name => { options => $options } })
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

      create_resources('teneleven::docker::provision', { $name => { run_options => $options } })
    }
  }

  if (!empty($compose)) {
    $compose.each |$app_name, $app_type| {
      create_resources('teneleven::docker::compose', { $app_name => { app_type => $app_type } })
    }
  }
}
