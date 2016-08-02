/**
 * Run something in a container using docker::exec
 */
define teneleven::docker::exec (
  $container = $title,

  /* docker::exec options */
  $options   = {}
) {
  include ::teneleven::docker

  create_resources('::docker::exec', { "exec-${title}" => merge({
    container     => $container,
    sanitise_name => false,
  }, $options)})
}
