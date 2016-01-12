class teneleven (
  $packages = [],
  $commands = [],
  $programs = {}
) {
  include apt
  include teneleven::params

  # global supervisord setup for containers
  class { 'supervisord':
    install_pip  => true,
    install_init => false,
    service_manage => false
  }

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

  package { $packages:
    ensure  => present
  }

  $commands.each |$command| {
    exec { $command:
      command  => $command,
      path     => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      onlyif   => 'pgrep supervisord' # todo make smarter
    }
  }

  create_resources('supervisord::program', $programs)
}
