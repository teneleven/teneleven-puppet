#!/bin/sh

if [ -z "$FACTER_puppet_dir" ]; then
    export FACTER_puppet_dir="$(pwd)/puppet"
fi

if [ -z "$FACTER_volume_dir" ]; then
    if [ -d "$(pwd)/volumes" ]; then
        export FACTER_volume_dir="$(pwd)/volumes"
    elif [ -d /var/volumes ]; then
        export FACTER_volume_dir=/var/volumes
    elif [ -d /volumes ]; then
        export FACTER_volume_dir=/volumes
    fi
fi

if ! [ -z "$1" ]; then
    export FACTER_hostname="$1"
fi

EXTRA_ARGS=""
if [ `puppet --version | cut -c1` -eq "3" ]; then
    # iterators!
    EXTRA_ARGS="--parser=future"
fi

if ! [ -z "$FACTER_is_container" ]; then
    # do this so we don't get errors on apt install
    apt-get update --fix-missing -y;
fi

puppet apply \
  --modulepath "$FACTER_puppet_dir/modules"      \
  --hiera_config "$FACTER_puppet_dir/hiera.yaml" \
  $EXTRA_ARGS                             \
  "$FACTER_puppet_dir/manifests";
