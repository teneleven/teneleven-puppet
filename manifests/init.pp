class teneleven (
  $packages = [],
  $commands = [],
  $programs = {},
  $supervisorctl_command = '/usr/bin/supervisorctl',

  $apt_mirror = 'http://archive.ubuntu.com/ubuntu',
) {

  hiera_include('classes', {})

  include teneleven::params

  if ($::is_container) {
    Service {
      provider => 'base'
    }

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

    class { teneleven::apt:
      source => $apt_mirror,
      update => true,
    } -> class { teneleven::hiera: }
  } else {
    class { teneleven::apt: } -> class { teneleven::hiera: }
  }

  Class['teneleven::apt'] -> package { $packages: ensure => present }

  $commands.each |$command| {
    exec { $command:
      command  => $command,
      path     => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      onlyif   => 'pgrep supervisord' # todo make smarter
    }
  }

  create_resources('supervisord::program', $programs)

}
