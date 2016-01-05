#!/bin/sh

if [ -z "$puppet_dir" ]; then
    puppet_dir='./puppet'
fi

puppet apply \
  --modulepath "$puppet_dir/modules" \
  --hiera_config "$puppet_dir/hiera.yaml" \
  "$puppet_dir/manifests";
