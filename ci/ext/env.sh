#!/bin/bash
set -e

if [ -z $BUILD_ALL ]
then
    export RELEASE_NAME="$stack_id-v$stack_version"
else
    if [ -f $base_dir/VERSION ]; then
        export RELEASE_NAME="$(cat $base_dir/VERSION)"
    else
        export RELEASE_NAME="$BUILD_ALL"
    fi
fi
