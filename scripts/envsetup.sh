#!/bin/bash

boardlist="i386 x86_64 arm-goldfishv7"

board() {
    id=$1

    if [ "$id" = "" ]; then
	echo arch: ${ARCH-"<not set>"}
	echo board: ${BOARD-"<not set>"}
	return 0
    fi

    arch=${id/-*/}
    board=${id/*-/}
    if [ "$arch" = "$board" ]; then
	board=default
    fi
    export ARCH=$arch BOARD=$board
    mkdir -p out/build-$ARCH-$BOARD
    ln -sfn out/build-$ARCH-$BOARD build
}

_board() {
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
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
