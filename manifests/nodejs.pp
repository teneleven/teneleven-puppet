class teneleven::nodejs (
  $settings = {},
  $packages = [] /* list of NPM packages */
) {
  create_resources('class', { ::nodejs => $settings })

  $packages.each |$name, $package| {
    if (is_hash($package)) {
      create_resources('::package', { $name => $package })
    } else {
      package { $package: }
    }
  }
}
