#!/bin/bash

CONFIG_SHARED="--host=$TARGET --build=$MACHTYPE --prefix=/usr --exec-prefix=/ --sysconfdir=/etc --localstatedir=/var --disable-nls --disable-rpath"

BOOT_PART_NO=1
ROOT_PART_NO=3

PACKAGES="
linux-rpi
ncurses
zlib
libressl
libpipeline
gdbm
readline
bash
coreutils
util-linux
grep
sed
gawk
less
tar
gzip
which
patch
diffutils
findutils
procps
vim
kmod
sysvinit
insserv
lfs-bootscripts
shadow-utils
net-tools
libmnl
iproute2
dhcpcd
e2fsprogs
dosfstools
openssh
file
groff
man-db
u-boot
firmware
configs
"

DIR=$(dirname "`readlink -f \"$0\"`")
BUILD_DIR="/opt/arm/distro/build"
PACKAGES_DIR="$DIR/packages"
REPOS_DIR="/opt/arm/distro/repos"
SRC_DIR="$HOME/src"
BUILD_LOG="$BUILD_DIR/build.log"
BOOTPART_DIR="$BUILD_DIR/bootpart"
HOSTTOOLS_DIR="$BUILD_DIR/host-tools"
export PKG_CONFIG_PATH=""
export PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/share/pkgconfig"

echo1 () {
	echo -e "\e[1;33m$*\e[0m"
}

echo2 () {
	echo -e "\e[0;33m$*\e[0m"
}

echo_err () {
	echo -e "\e[31m$*\e[0m" 1>&2
}

check_env () {
	if [ -z "$TARGET" ]; then
		echo_err "Environment variable TARGET is not set. This should be set to a GNU target triplet."
		exit 1
	fi
	if [ -z "$TOOLCHAIN" ]; then
		echo_err "Environment variable TOOLCHAIN is not set. This should be set to the toolchain's root directory."
		exit 1
	fi
	if [ -z "$SYSROOT" ]; then
		echo_err "Environment variable SYSROOT is not set. This should be set to the target system root directory."
		exit 1
	fi
}

sysroot-overlay-is-mounted () {
	[ `mount | grep $TARGET-sysroot-overlay | wc -l` -eq 2 ]
}

sysroot-overlay-erase () {
	if sysroot-overlay-is-mounted; then
		echo >&2 "Sysroot overlay is mounted!"
		return 1
	fi

	cd $TOOLCHAIN/$TARGET
	sudo rm -rf sysroot-overlay-upper
}

sysroot-overlay-mount () {
	if sysroot-overlay-is-mounted; then
		return 0
	fi

	cd $TOOLCHAIN/$TARGET
	mkdir -p sysroot-overlay-upper sysroot-overlay-workdir sysroot-overlay-merged || return 1
	sudo mount -t overlay $TARGET-sysroot-overlay -olowerdir=$SYSROOT,upperdir=sysroot-overlay-upper,workdir=sysroot-overlay-workdir sysroot-overlay-merged || return 1
	sudo mount --bind sysroot-overlay-merged $SYSROOT || return 1
}

sysroot-overlay-umount () {
	if ! sysroot-overlay-is-mounted; then
		return 0
	fi
	sudo umount $SYSROOT || return 1
	sudo umount $TARGET-sysroot-overlay || return 1
}

sysroot_prepare () {
	echo1 "Preparing sysroot"
	sysroot-overlay-umount || return 1
	sysroot-overlay-erase || return 1
	sudo chown -R root:root $SYSROOT
	sysroot-overlay-mount || return 1
	cd $SYSROOT
	sudo mkdir -p boot boot/firmware dev etc/opt home media mnt opt proc root run srv sys tmp usr/local var/{cache,lib,local,lock,log,opt,spool,tmp}
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

prepare_partitions () {
	echo2 "Creating partitions"
	sudo /usr/sbin/parted -s $TARGET_DEV mklabel msdos || return 1
	sudo /usr/sbin/parted -s -a opt $TARGET_DEV mkpart primary fat32 1 50M || return 1
	sudo /usr/sbin/parted -s -a opt $TARGET_DEV mkpart primary linux-swap 50M 1G || return 1
	sudo /usr/sbin/parted -s -a opt $TARGET_DEV mkpart primary ext4 1G 100% || return 1
	echo2 "Creating boot filesystem"
	sudo /sbin/mkfs.vfat ${TARGET_DEV}1 || return 1
	echo2 "Creating swap"
	sudo /sbin/mkswap ${TARGET_DEV}2 || return 1
	echo2 "Creating root filesystem"
	echo y | sudo /sbin/mkfs.ext4 ${TARGET_DEV}3 || return 1
}

do_install_to_target () {
	if [ -z "$@" ]; then
		echo2 "Copying root partition files"
		sudo rm -rf $ROOT_DIR/*
		sudo cp -a "$SYSROOT"/* $ROOT_DIR || return 1

		echo2 "Copying boot partition files"
		sudo rm -rf $BOOT_DIR/*
		sudo cp -r "$BOOTPART_DIR"/* $BOOT_DIR || return 1
	else
		OPT_NOCLEAN=1
		INSTALL_TO_TARGET=1
		SYSROOT=$ROOT_DIR
		BOOTPART_DIR=$BOOT_DIR
		for PKG in "$@"; do
			build_package || return 1
		done
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
	shift 1

	prepare_partitions || return 1

	if ! BOOT_PART=`find_partition_dev $TARGET_DEV $BOOT_PART_NO`; then
		echo_err "Can't find partition $BOOT_PART_NO on device $TARGET_DEV"
		exit 1
	fi
	if ! ROOT_PART=`find_partition_dev $TARGET_DEV $ROOT_PART_NO`; then
		echo_err "Can't find partition $BOOT_PART_NO on device $TARGET_DEV"
		exit 1
	fi

	ROOT_DIR=`mktemp -d`
	BOOT_DIR=`mktemp -d`

	sudo umount $ROOT_PART >/dev/null 2>&1
	sudo umount $BOOT_PART >/dev/null 2>&1

	sudo mount $ROOT_PART $ROOT_DIR || return 1
	sudo mount $BOOT_PART $BOOT_DIR || return 1

	do_install_to_target "$@"
	local ret=$?

	sudo umount $ROOT_DIR && rmdir $ROOT_DIR
	sudo umount $BOOT_DIR && rmdir $BOOT_DIR

	return $ret
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
	local tar_dir=`tar tf "$SRC_DIR/$f" | head -1 | cut -d/ -f1`
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
		SRC_EXISTS=1
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
	PKG_DIR=$PACKAGES_DIR/$PKG
	if ! source $PKG_DIR/package.sh; then
		echo_err "No descriptor file found for package $PKG"
		exit 1
	fi

	echo -e "\e[1;34m---- $PKG ----\e[0m"

	get_source || return 1

	if [ ! "$INSTALL_TO_TARGET" ]; then
		if [ ! "$OPT_NOCLEAN" ] || [ $SRC_EXISTS -eq 0 ]; then
			echo2 "Prepare"
			do_step prepare || return 1
		fi
		echo2 "Build"
		do_step build || return 1
		echo2 "Install"
	fi
	do_step install || return 1

	unset -f prepare build install
	unset PKG_DIR SRC_TAR_URL SRC_GIT_URL
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
	mkdir -p "$BUILD_DIR" "$BOOTPART_DIR" "$HOSTTOOLS_DIR" || return 1
	for PKG in `echo "$packages" | grep -v ^\#`; do
		build_package $PKG || return 1
	done
}

usage () {
	echo "\
Usage: $(basename $0) [OPTION]... [COMMAND] [DEVICE] [PACKAGE]...

  -h    show help
  -v    verbose output
  -c    don't clean sysroot and build directories

COMMAND can be:
  build      build entire system or individual PACKAGE(s)
  install    install entire system or individual PACKAGE(s) to DEVICE

Empty command equals to 'build entire system'.
"
}

main () {
	check_env
	if [ -z "$1" ] || [ "$1" = "build" ]; then
		shift 1
		build_packages "$@" || return 1
	elif [ "$1" = "install" ]; then
		shift 1
		install_to_target "$@" || return 1
	else
		echo_err "Unknown command: $1. Use -h to show usage."
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
		echo_err "Invalid Option: $OPTARG. Use -h to show usage."
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

