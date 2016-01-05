/* represents a base container that provisions itself using puppet */
class teneleven::container::puppet (
  $docker_dir = 'modules/teneleven/'
) {
  docker::image { "puppet":
    docker_dir => $docker_dir
  }
}
