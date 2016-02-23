define teneleven::container::provision (
  $run_options  = {},
  $puppet_mount = undef,
) {
  include ::teneleven::params
  include ::teneleven::container::base

  create_resources('::teneleven::container::run', { $title => {
    puppet_mount => $puppet_mount,
    options      => merge({
      command => 'sh -c "/provision.sh; supervisord -n"'
    }, $run_options),
  }})
}
