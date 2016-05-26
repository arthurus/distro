#!/bin/bash

CONFIG_SHARED="--host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr --exec-prefix=/ --sysconfdir=/etc --disable-nls"

BOOT_PART_NO=1
ROOT_PART_NO=3

PACKAGES="
linux-rpi
bash
coreutils
util-linux
grep
sed
findutils
ncurses
procps
vim
kmod
sysvinit
lfs-bootscripts
shadow-utils
net-tools
u-boot
firmware
"

DIR=$(dirname "`readlink -f \"$0\"`")
BUILD_DIR="/opt/arm/distro/build"
PKG_DIR="$DIR/packages"
REPOS_DIR="/opt/arm/distro/repos"
SRC_DIR="$HOME/src"
BUILD_LOG="$DIR/build.log"
BOOTPART_DIR="$BUILD_DIR/bootpart"

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
	sysroot-overlay-umount || return 1
	sysroot-overlay-erase || return 1
	sudo chown -R root:root $SYSROOT
	sysroot-overlay-mount || return 1
	cd $SYSROOT
	sudo mkdir -p boot dev media mnt opt proc root run sys tmp var/log
	sudo ln -sf ../run var/run 
}

install_to_sysroot () {
	sudo -E make DESTDIR=$SYSROOT install
}

find_partition_dev () {
	local dev=$1
	local part=$2
	if [ -b "${dev}p$2" ]; then
		echo "${dev}p$2"
	elif [ -b "$dev$2" ]; then
		echo "$dev$2"
	else
		return 1
	fi
}

install_to_target () {
	echo1 "Installing to target"
	if [ -z "$1" ]; then
		echo_err "Target block device path not provided"
		exit 1
	fi
	TARGET_DEV="$1"
	if [ ! -b "$TARGET_DEV" ]; then
		echo_err "Target block device $TARGET_DEV does not exist"
		exit 1
	fi

	if ! BOOT_PART=`find_partition_dev $TARGET_DEV $BOOT_PART_NO`; then
		echo_err "Can't find partition $BOOT_PART_NO on device $TARGET_DEV"
		exit 1
	fi
	if ! ROOT_PART=`find_partition_dev $TARGET_DEV $ROOT_PART_NO`; then
		echo_err "Can't find partition $BOOT_PART_NO on device $TARGET_DEV"
		exit 1
	fi

	sudo umount $BOOT_PART >/dev/null 2>&1
	sudo umount $ROOT_PART >/dev/null 2>&1

	echo2 "Copying root partition files"
	sudo mount $ROOT_PART /mnt || return 1
	sudo rm -rf /mnt/*
	sudo cp -a $SYSROOT/* /mnt || return 1
	sudo umount /mnt

	echo2 "Copying boot partition files"
	sudo mount $BOOT_PART /mnt || return 1
	sudo rm -rf /mnt/*
	sudo cp -r $BOOTPART_DIR/* /mnt || return 1
	sudo umount /mnt
}

get_source_tar () {
	mkdir -p "$SRC_DIR"
	cd "$SRC_DIR"

	local f=`basename "$SRC_TAR_URL"`
	if ! echo $f | grep -q $PKG; then
		f=$PKG-$f
	fi

	if ! [ -e $f ]; then
		echo "Downloading $f from $SRC_TAR_URL"
		[ ! "$OPT_VERBOSE" ] && local wget_log="-a $BUILD_LOG"
		if ! wget -nc $wget_log -O $f "$SRC_TAR_URL" || ! test -e $f; then
			echo_err "Failed to download $f"
			exit 1
		fi
	fi

	cd $BUILD_DIR
	local tar_dir=`tar tf "$SRC_DIR/$f" | head -1`
	if [ -d "$tar_dir" ] && [ "$OPT_NOCLEAN" ]; then
		SRC_EXISTS=1
		cd "$tar_dir" && return 0
	fi

	echo "Extracting $f"
	tar xf "$SRC_DIR/$f" && cd "$tar_dir"
}

get_source_git () {
	mkdir -p "$REPOS_DIR"
	cd "$REPOS_DIR"

	if [ -d $PKG ]; then
		SRC_EXISTS=1
		cd $PKG && return 0
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
	SRC_EXISTS=0
	if [ -n "$SRC_TAR_URL" ]; then
		get_source_tar
	elif [ -n "$SRC_GIT_URL" ]; then
		get_source_git
	else
		echo_err "No URL to get source"
		exit 1
	fi
}

do_step () {
	local step="$1"
	if [ -z "step" ]; then
		return 1
	fi
	if [ "$OPT_VERBOSE" ]; then
		$step || return 1
	else
		$step >>"$BUILD_LOG" 2>&1 || return 1
	fi
}

build_package () {
	if ! source $PKG_DIR/$PKG.sh; then
		echo_err "No descriptor file found for package $PKG"
		exit 1
	fi

	echo -e "\e[1;34m---- $PKG ----\e[0m"

	echo2 "Get source"
	get_source || return 1

	if [ ! "$OPT_NOCLEAN" ] || [ $SRC_EXISTS -eq 0 ]; then
		echo2 "Prepare"
		do_step prepare || return 1
	fi
	echo2 "Build"
	do_step build || return 1
	echo2 "Install"
	do_step install || return 1

	unset -f prepare build install
	unset SRC_TAR_URL SRC_GIT_URL 
}

build_packages () {
	if ! [ "$OPT_NOCLEAN" ]; then
		sysroot_prepare || return 1
		rm -rf $BUILD_DIR || return 1
	else
		sysroot-overlay-mount || return 1
	fi
	echo1 "Building packages"
	rm -f $BUILD_LOG
	local packages="$@"
	if [ -z "$packages" ]; then
		packages="$PACKAGES"
	fi
	mkdir -p "$BUILD_DIR" "$BOOTPART_DIR" || return 1
	for PKG in `echo "$packages" | grep -v ^\#`; do
		build_package $PKG || return 1
	done
	echo1 "Removing docs"
	sudo rm -rf $SYSROOT/usr/share/doc
	sudo rm -rf $SYSROOT/usr/share/man
}

usage () {
	echo "Usage:"
}

main () {
	if [ -z "$1" ] || [ "$1" = "build" ]; then
		if ! [ -z "$2" ]; then
			shift 1
		fi
		build_packages "$@" || return 1
	elif [ "$1" = "install" ]; then
		install_to_target "$2" || return 1
	else
		echo_err "Unknown command: $1"
		exit 1
	fi
}

while getopts ":hvc" OPT; do
	case $OPT in
	h)
		usage
		exit
		;;
	v)
		OPT_VERBOSE=1
		;;
	c)
		OPT_NOCLEAN=1
		;;
	\?)
		echo_err "Invalid Option: $OPTARG"
		exit 1
		;;
	esac
done
shift $((OPTIND -1))

if main "$@"; then
	echo1 Done
else
	[ ! "$OPT_VERBOSE" ] && echo_err "Something went wrong. Run again with -v or see build.log for details."
	exit 1
fi

