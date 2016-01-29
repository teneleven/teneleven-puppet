define teneleven::container::provision (
  $run_options  = {},
  $puppet_mount = $teneleven::params::puppet_mount,
) {
  include ::teneleven::params
  include ::teneleven::container::base

  create_resources('::teneleven::container::run', { $title => {
    options      => $run_options,
    puppet_mount => $puppet_mount,
  }})

  ::docker::exec { "${title}-provision":
    container => $title,
    command   => '/provision.sh',
    detach    => true,
  }

  Teneleven::Container::Run[$title] -> Docker::Exec["${title}-provision"]
}
