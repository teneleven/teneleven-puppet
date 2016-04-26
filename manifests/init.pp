class teneleven (
  $packages   = [],
  $commands   = [],
  $programs   = {},
  $load_hiera = true,
  $supervisorctl_command = '/usr/bin/supervisorctl',
) {

  if ($::is_container) {
    /* setup some helpful defaults for docker */

    include teneleven::params

    Service {
      provider => 'base'
    }

    /* the uid & gid are important assume its all 1000 pending better method */
    group { $teneleven::params::web_group:
      ensure => present,
      gid => $teneleven::params::web_gid,
    }
    user { $teneleven::params::web_user:
      ensure => present,
      gid => $teneleven::params::web_gid,
      uid => $teneleven::params::web_uid,
    }

    # global supervisord setup for containers
    class { 'supervisord':
      install_pip    => true,
      install_init   => false,
      service_manage => false,
      executable_ctl => $supervisorctl_command,
    }

    /* refresh supervisord for each program */
    /* Supervisord::Program <| |> -> exec { 'reload-supervisord': */
    /*   command => "${::teneleven::supervisorctl_command} reload", */
    /* } */

  }

  if $load_hiera {
    /* parse teneleven hiera config */
    hiera_hash('teneleven', {}).each |$name, $option| {
      create_resources('class', { "::teneleven::${name}" => $option })
    }
  }

  /* TODO ensure the following is preserved: */

  /* if (!empty($full_programs)) { */
  /*   create_resources('supervisord::program', $full_programs) */
  /* } */

  /* if (!empty($full_commands)) { */
  /*   Exec['reload-supervisord'] -> exec { $full_commands: */
  /*     path   => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'] */
  /*   } */
  /* } */

}
