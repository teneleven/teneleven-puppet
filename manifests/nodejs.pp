class teneleven::nodejs (
  $settings = {},
  $packages = [] /* list of NPM packages */
) {
  create_resources('class', { ::nodejs => $settings })

  $packages.each |$name, $package| {
    if (is_hash($package)) {
      create_resources('::package', { $name => merge({ provider => 'npm' }, $package) })
    } else {
      package { $package: provider => 'npm' }
    }
  }
}
