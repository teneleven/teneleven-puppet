class teneleven (
  $packages = [],
  $commands = [],
  $programs = {},
  $supervisorctl_command = '/usr/bin/supervisorctl',
) {

  $apache        = hiera_hash('apache', {})
  $php           = hiera_hash('php', {})
  $nginx         = hiera_hash('nginx', {})
  $docker        = hiera_hash('docker', {})
  $full_programs = hiera_hash('programs', $programs)
  $full_packages = hiera_array('packages', $packages)
  $full_commands = hiera_array('commands', $commands)

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
    Supervisord::Program <| |> -> exec { 'reload-supervisord':
      command => "${::teneleven::supervisorctl_command} reload",
    }

  }

  /* do stuff from hiera config */

  include teneleven::apt

  if (!empty($php)) {
    create_resources('class', { teneleven::fpm => $php })
  }

  if (!empty($apache)) {
    create_resources('class', { teneleven::apache => $apache })
  }

  if (!empty($nginx)) {
    create_resources('class', { teneleven::nginx => $nginx })
  }

  if (!empty($docker)) {
    create_resources('class', { teneleven::docker => $docker })
  }

  if (!empty($full_programs)) {
    create_resources('supervisord::program', $full_programs)
  }

  if (!empty($full_packages)) {
    Class['teneleven::apt'] -> package { $full_packages: ensure => present }
  }

  if (!empty($full_commands)) {
    Exec['reload-supervisord'] -> exec { $full_commands:
      path   => ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
    }
  }

}
