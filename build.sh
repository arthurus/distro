#!/bin/bash

CONFIG_SHARED="--host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr --exec-prefix=/ --sysconfdir=/etc --disable-nls"
DIR=$(dirname "`readlink -f \"$0\"`")

BOOT_PART=/dev/sde1
ROOT_PART=/dev/sde3

PACKAGES="
linux-rpi
bash
coreutils
util-linux
grep
findutils
ncurses
procps
vim
kmod
"

BUILD_DIR="$DIR/build"
PKG_DIR="$DIR/packages"
REPOS_DIR="$DIR/repos"
SRC_DIR="$HOME/src"
BUILD_LOG="$DIR/build.log"

echo1 () {
	echo -e "\e[1;33m$*\e[0m"
}

echo2 () {
	echo -e "\e[0;33m$*\e[0m"
}

echo_err () {
	echo -e "\e[31m$*\e[0m" 1>&2
}

sysroot_prepare () {
	echo1 "Preparing sysroot"
	sysroot-overlay-umount
	sysroot-overlay-erase
	sudo chown -R root:root $SYSROOT
	sysroot-overlay-mount
	cd $SYSROOT
	sudo mkdir -p boot dev media mnt opt proc run sys tmp 
	sudo ln -sf ../run var/run 
}

install_to_sysroot () {
	sudo -E make DESTDIR=$SYSROOT install
}

install_to_target () {
	echo1 "Installing to target"
	sudo umount $BOOT_PART >/dev/null 2>&1
	sudo umount $ROOT_PART >/dev/null 2>&1
	# TODO: u-boot, put kernel in main filesystem
	sudo mount $BOOT_PART /mnt || return 1
	sudo cp $REPOS_DIR/linux-rpi/arch/arm/boot/zImage /mnt/kernel.img || return 1
	sudo umount /mnt

	sudo mount $ROOT_PART /mnt || return 1
	sudo rm -rf /mnt/*
	sudo cp -a $SYSROOT/* /mnt || return 1
	sudo umount /mnt
}

get_source_tar () {
	mkdir -p "$SRC_DIR"
	cd "$SRC_DIR"

	local f=`basename "$SRC_TAR_URL"`
	if ! [ -e $f ]; then
		echo "Downloading $f from $SRC_TAR_URL"
		[ ! "$OPT_VERBOSE" ] && local wget_log="-a $BUILD_LOG"
		if ! wget -nc $wget_log "$SRC_TAR_URL" || ! test -e $f; then
			echo_err "Failed to download $f"
			return 1
		fi
	fi

	cd $BUILD_DIR

	echo "Extracting $f"
	tar xf "$SRC_DIR/$f" && cd `tar tf "$SRC_DIR/$f" | head -1`
}

get_source_git () {
	mkdir -p "$REPOS_DIR"
	cd "$REPOS_DIR"

	if [ -d $PKG ]; then
		cd $PKG
		return 0
	fi

	echo "Cloning git repository from $SRC_GIT_URL"
	if [ "$OPT_VERBOSE" ]; then
		git clone "$SRC_GIT_URL" $PKG || return 1
	else
		git clone "$SRC_GIT_URL" $PKG >>"$BUILD_LOG" 2>&1 || return 1
	fi

	cd $PKG
}

get_source () {
	if [ -n "$SRC_TAR_URL" ]; then
		get_source_tar
	elif [ -n "$SRC_GIT_URL" ]; then
		get_source_git
	else
		echo_err "No URL to get source"
		return 1
	fi
}

build_package () {
	source $PKG_DIR/$PKG.sh || return 1

	echo2 "Get source"
	get_source || return 1

	if [ "$OPT_VERBOSE" ]; then
		echo2 "Prepare"
		prepare || return 1
		echo2 "Build"
		build || return 1
		echo2 "Install"
		install || return 1
	else
		echo2 "Prepare"
		prepare >>"$BUILD_LOG" 2>&1 || return 1
		echo2 "Build"
		build >>"$BUILD_LOG" 2>&1 || return 1
		echo2 "Install"
		install >>"$BUILD_LOG" 2>&1 || return 1
	fi

	unset -f prepare build install
	unset SRC_TAR_URL SRC_GIT_URL 
}

build_packages () {
	echo1 "Building packages"
	rm -f $BUILD_LOG
	rm -rf $BUILD_DIR && mkdir $BUILD_DIR
	for PKG in $PACKAGES; do
		echo -e "\e[1;34m---- $PKG ----\e[0m"
		build_package $PKG || return 1
	done
	echo2 "Removing docs"
	sudo rm -rf $SYSROOT/usr/share/doc
	sudo rm -rf $SYSROOT/usr/share/man
}

usage () {
	echo "Usage:"
}

main () {
	if [ -z "$1" ]; then
		sysroot_prepare || return 1
		build_packages || return 1
	elif [ "$1" = "install" ]; then
		install_to_target || return 1
	else
		echo_err "Unknown command: $1"
		return 1
	fi
}

while getopts ":hvn" OPT; do
	case $OPT in
	h)
		usage
		exit
		;;
	v)
		OPT_VERBOSE=1
		;;
	n)
		OPT_NOCLEAN=1
		;;
	\?)
		echo_err "Invalid Option: $OPTARG"
		exit 1
		;;
	esac
done
shift $((OPTIND -1))

if main $1; then
	echo1 Done
else
	[ ! "$OPT_VERBOSE" ] && echo_err "Something went wrong. Run again with -v or see build.log for details."
	exit 1
fi

