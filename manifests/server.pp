class teneleven::server (
  $exec          = [],
  $exec_defaults = {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin']
  },

  $files            = {},

  $packages         = [],
  $package_defaults = {},

  $users            = {},

  $acls             = {},
  $default_acls     = []
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

  $files.each |$name,$options| {
    create_resources('file', { $name => $options })
  }

  $exec.each |$name,$options| {
    if (is_hash($options)) {
      create_resources('exec', { $name => merge(
        $exec_defaults,
        $options
      ) })
    } else {
      $exe = $options

      create_resources('exec', { "server_exec_${exe}" => merge(
        $exec_defaults,
        { command => $exe }
      ) })

      if (!empty($packages)) {
        Class['::teneleven::apt'] -> Exec["server_exec_${exe}"]
      }
    }
  }

  $users.each |$user, $options| {
    if ($options['groups']) {
      ensure_resource('group', $options['groups'], { ensure => present })
    }

    create_resources('user', { "server_user_${user}" => $options })
  }

  $acls.each |$file, $permissions| {
    create_resources('::fooacl::conf', {"server_acl_${file}" => {
      target      => $file,
      permissions => concat($default_acls, $permissions)
    }})
  }
}
