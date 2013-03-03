#!/bin/bash

board() {
    local id=$1

    if [ "$id" = "" ]; then
	echo arch: ${ARCH-"<not set>"}
	echo board: ${BOARD-"<not set>"}
	return 0
    fi

    local arch=${id/-*/}
    local board=${id/*-/}
    if [ "$arch" = "$board" ]; then
	board=default
    fi
    export ARCH=$arch BOARD=$board
    mkdir -p out/build-$ARCH-$BOARD
    ln -sfn out/build-$ARCH-$BOARD build
}

_board() {
    local boardlist="i386 x86_64 arm-goldfishv7"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=()

    case "$prev" in
        board)
            COMPREPLY=($(compgen -W "$boardlist" -- $cur))
            return 0
            ;;
        *)
            ;;
    esac
}

complete -F _board board
