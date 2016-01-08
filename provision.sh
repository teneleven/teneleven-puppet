#!/bin/sh

if [ -z "$puppet_dir" ]; then
    puppet_dir='./puppet'
fi

if ! [ -z "$1" ]; then
    export FACTER_hostname="$1"
fi

puppet apply \
  --modulepath "$puppet_dir/modules" \
  --hiera_config "$puppet_dir/hiera.yaml" \
  "$puppet_dir/manifests";
