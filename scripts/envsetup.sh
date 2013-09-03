#!/bin/bash

load_scripts() {
    local currentdir=`dirname ${BASH_SOURCE[0]}`
    export TOPLEVEL_DIR=`realpath $currentdir`
    export BUILD_DIR=$TOPLEVEL_DIR/../build

    source $currentdir/board.sh
    source $currentdir/component.sh
}

load_scripts
