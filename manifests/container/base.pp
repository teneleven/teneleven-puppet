/* represents a base container that provisions itself using puppet */
class teneleven::container::base (
  $dir        = 'puppet',
  $docker_dir = 'puppet/modules/teneleven/'
) {
  docker::image { 'base':
    docker_dir => $docker_dir,
    ensure     => latest
  }
}
