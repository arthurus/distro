SRC_TAR_URL="https://www.kernel.org/pub/linux/utils/util-linux/v2.28/util-linux-2.28.tar.xz"

prepare () {
	./autogen.sh
	./configure $CONFIG_SHARED --libdir=/usr/lib --without-python
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
