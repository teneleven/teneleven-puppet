class teneleven::hiera () {

  $apache = hiera_hash('apache', {})
  $php    = hiera_hash('php', {})
  $nginx  = hiera_hash('nginx', {})

  if (!empty($php)) {
    create_resources('class', { teneleven::fpm => $php })
    contain '::teneleven::fpm'
  }

  if (!empty($apache)) {
    create_resources('class', { teneleven::apache => $apache })
    contain '::teneleven::apache'
  }

  if (!empty($nginx)) {
    create_resources('class', { teneleven::nginx => $nginx })
    /* contain '::teneleven::nginx' */
  }

}
