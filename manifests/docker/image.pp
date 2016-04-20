/* represents a base container that provisions itself using puppet */
class teneleven::docker::image (
  $image_name = 'base',
  $docker_dir = 'puppet/modules/teneleven/'
) {
  docker::image { $image_name:
    docker_dir => $docker_dir,
    ensure     => latest,
  }
}
