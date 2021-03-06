SRC_TAR_URL="https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-22.tar.xz"

prepare () {
	./configure $CONFIG_SHARED --libdir=/usr/lib
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot || return 1
	for target in depmod insmod lsmod modinfo modprobe rmmod; do
		sudo ln -sfv ../bin/kmod $SYSROOT/sbin/$target
	done
	sudo ln -sfv kmod $SYSROOT/bin/lsmod
}
