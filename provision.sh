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

# detect if we get future parser (for iterators)
if [ `puppet --version | cut -c1` -eq "3" ]; then
    EXTRA_ARGS="--parser=future"
else
    EXTRA_ARGS=""
fi

# detect manifest location
if [ -f "$FACTER_puppet_dir/manifests/provision.pp" ]; then
    MANIFEST_DIR="$FACTER_puppet_dir/manifests/provision.pp"
else
    MANIFEST_DIR="$FACTER_puppet_dir/manifests"
fi

puppet apply \
  --modulepath "$FACTER_puppet_dir/modules"      \
  --hiera_config "$FACTER_puppet_dir/hiera.yaml" \
  $EXTRA_ARGS                                    \
  $MANIFEST_DIR;
