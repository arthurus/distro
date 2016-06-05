SRC_TAR_URL="https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.4.0.tar.gz"

prepare () {
	CC=${CROSS_COMPILE}gcc AR=${CROSS_COMPILE}ar ./configure
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
