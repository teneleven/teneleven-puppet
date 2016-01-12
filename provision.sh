#!/bin/sh

if [ -z "$puppet_dir" ]; then
    puppet_dir='./puppet'
fi

if ! [ -z "$1" ]; then
    export FACTER_hostname="$1"
fi

export FACTER_cwd=$(pwd)

EXTRA_ARGS=""
if [ `puppet --version | cut -c1` -eq "3" ]; then
    # iterators!
    EXTRA_ARGS="--parser=future"
fi

puppet apply \
  --modulepath "$puppet_dir/modules"      \
  --hiera_config "$puppet_dir/hiera.yaml" \
  $EXTRA_ARGS                             \
  "$puppet_dir/manifests";
