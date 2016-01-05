class teneleven {
  include apt
  include params

  # global supervisord setup for containers
  class { 'supervisord':
    install_pip  => true,
    install_init => false,
    service_manage => false
  }

  group { $params::web_group:
    ensure => present,
    gid => $params::web_gid,
  }

  user { $params::web_user:
    ensure => present,
    gid => $params::web_gid,
    uid => $params::web_uid,
  }
}
