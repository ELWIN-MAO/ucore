#!/bin/bash

# Exit with 0 if the arch/board is supported by the component
# No argument
test_supported () {
    BOARD_POSSIBLE=($(compgen -W "$BOARD_SUPPORTED" -- $ARCH))
    if [ "$BOARD_POSSIBLE" = "" ]; then
	exit 1
    fi

    if echo $BOARD_POSSIBLE | grep "\b$ARCH-*\b" > /dev/null; then
	exit 0
    fi

    if echo $BOARD_POSSIBLE | grep "\b$ARCH-$BOARD\b" > /dev/null; then
	exit 0
    fi

    exit 1
}

INFO_FILE=$TOPLEVEL_DIR/scripts/glues/$1/info
if [ ! -f $INFO_FILE ]; then
    exit 1
fi
source $INFO_FILE

case "$2" in
    supported)
	test_supported
	;;
    *)
	exit 1
esac
