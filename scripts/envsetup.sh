#!/bin/bash

load_scripts() {
    local currentdir=`dirname ${BASH_SOURCE[0]}`
    export BUILD_DIR=`realpath $currentdir`/../build

    source $currentdir/board.sh
    source $currentdir/component.sh
}

load_scripts
