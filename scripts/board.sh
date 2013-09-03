#!/bin/bash

_boardlist=" `find kernel | grep "arch/.*/configs/.*_defconfig" | sed "s/.*arch\/\(.*\)\/configs\/\(.*\)_defconfig/\1-\2/g" | sed "s/-default//g" | paste -s -d ' '` "

board() {
    local id=$1

    if [ "$id" = "" ]; then
	echo arch: ${ARCH-"<not set>"}
	echo board: ${BOARD-"<not set>"}
	return 0
    fi

    if ! echo "$_boardlist" | grep " $id " > /dev/null; then
	echo "Unknown board id: $id"
	echo "Supported:$_boardlist"
	return 1
    fi

    local arch=${id/-*/}
    local board=${id/*-/}
    if [ "$arch" = "$board" ]; then
	board=default
    fi
    export ARCH=$arch BOARD=$board
    mkdir -p out/build-$ARCH-$BOARD
    ln -sfn out/build-$ARCH-$BOARD $TOPLEVEL_DIR/build
}

_board() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=()

    case "$prev" in
        board)
            COMPREPLY=($(compgen -W "$_boardlist" -- $cur))
            return 0
            ;;
        *)
            ;;
    esac
}

complete -F _board board
