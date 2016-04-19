class teneleven::server (
  $exec          = [],
  $exec_defaults = {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
  },

  $packages         = [],
  $package_defaults = {}
) {
  if (!empty($packages)) {
    if $::osfamily == 'Debian' {
      class { '::teneleven::apt':
        packages => $packages
      }
    } else {
      fail("OS family ${::osfamily} not supported")
    }
  }

  $exec.each |$exe| {
    create_resources('exec', { "server_exec_${exe}" => merge(
      $exec_defaults,
      { command => $exe }
    ) })

    if (!empty($packages)) {
      Class['::teneleven::apt'] -> Exec["server_exec_${exe}"]
    }
  }
}
