define teneleven::docker::provision (
  $run_options  = {},
  $puppet_mount = undef,
) {
  include ::teneleven::docker
  include ::teneleven::docker::image

  Class[::teneleven::docker::image] -> Class[::teneleven::docker::run]

  create_resources('::teneleven::docker::run', { $title => {
    puppet_mount => $puppet_mount,
    options      => merge({
      command => 'sh -c "/provision.sh; supervisord -n"'
    }, $run_options),
  }})
}
