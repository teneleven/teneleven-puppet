class teneleven::hiera () {

  $apache = hiera_hash('apache', {})
  $php    = hiera_hash('php', {})
  $nginx  = hiera_hash('nginx', {})
  $packages = hiera_hash('packages', {})
  $commands = hiera_hash('commands', {})

  if (!empty($php)) {
    create_resources('class', { teneleven::fpm => $php })
    contain '::teneleven::fpm'
  }

  if (!empty($apache)) {
    create_resources('class', { teneleven::apache => $apache })
    contain '::teneleven::apache'
  }

  if (!empty($nginx)) {
    create_resources('class', { teneleven::nginx => $nginx })
    /* contain '::teneleven::nginx' */
  }


  if (!empty($packages)) {
    Class['teneleven::apt'] -> package { $packages: ensure => present }
  }

  $commands.each |$command| {
    exec { $command:
      command  => $command,
      path     => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      onlyif   => 'pgrep supervisord' # todo make smarter
    }
  }

}
