#!/bin/bash

# $1 - component dir
# $2 - component config file
check_component_enabled() {
    if [ `grep "COMPONENT_${1/\//_}=y" $2` ]; then
	printf "%-20s = yes\n" $1
    else
	printf "%-20s = no\n" $1
    fi
}

# $1 - component locally installed dir
# $2 - target directory
install_component() {
    local target_dir=`realpath $2`
    pushd $1 > /dev/null
    find . -type f | while read file; do
	local src=$file
	local target=$target_dir/$file
	if [ $src -nt $target ]; then
	    cp --parents -f $src $target_dir
	fi
    done
    popd > /dev/null
}

# $1 - component locally installed dir
# $2 - target directory
uninstall_component() {
    local target_dir=`realpath $2`
    pushd $1 > /dev/null
    find . -type f | while read file; do
	local target=$target_dir/$file
	if [ -e $target ]; then
	    rm -rf $target
	fi
    done
    popd > /dev/null
}

component() {
    local cmd=$1
    local config_file=$BUILD_DIR/.component-config
    local config_line="COMPONENT_${1/\//_}=y"

    if [ ! -e $config_file ]; then
	touch $config_file
    fi

    case "$1" in
	"")
            for comp in app/*; do
		check_component_enabled $comp $config_file
	    done
	    for comp in lib/*; do
		check_component_enabled $comp $config_file
	    done
            ;;
	app/* | lib/*)
            if [ "x$2" = "x" ]; then
		check_component_enabled $1 $config_file
	    else
		case "$2" in
		    "y")
			if [ ! `grep $config_line $config_file` ]; then
			    echo $config_line >> $config_file
			fi
			;;
		    "n")
			sed -i "/$config_line/d" $config_file
			;;
		    install)
			install_component $1/rootfs $BUILD_DIR/rootfs
			;;
		    uninstall)
			uninstall_component $1/rootfs $BUILD_DIR/rootfs
			;;
		esac
	    fi
	    ;;
	*)
	    ;;
    esac
}

_component() {
    local opts="y n install uninstall"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=()

    case "$prev" in
        component)
            COMPREPLY=($(compgen -W "`find app/ -mindepth 1 -maxdepth 1` `find lib/ -mindepth 1 -maxdepth 1`" -- $cur))
	    ;;
	app/* | lib/*)
	    COMPREPLY=($(compgen -W "$opts" -- $cur))
	    ;;
        *)
            ;;
    esac
}

case "$1" in
    "")
	complete -F _component component
	;;
    install)
	install_component $2 $3
	;;
    uninstall)
	uninstall_component $2 $3
	;;
    app/* | lib/*)
	component $1 $2
	;;
esac
