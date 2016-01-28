class teneleven::apt (
  $source = undef,
  $update = false
) {
  if ($source) {
    # configure apt sources
    ::apt::source { 'ubuntu':
      location => $source,
      release => $::lsbdistcodename,
      repos => 'main universe multiverse',
    }

    ::apt::source { 'ubuntu_updates':
      location => $source,
      release => "${::lsbdistcodename}-updates",
      repos => 'main universe multiverse',
    }

    ::apt::source { 'ubuntu_security':
      location => $source,
      release => "${::lsbdistcodename}-security",
      repos => 'main universe multiverse',
    }
  }

  if ($update) {
    class { '::apt':
      update => {
        frequency => 'always',
      }
    }

    contain '::apt::update'
  }

  contain '::apt'
}
