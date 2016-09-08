SRC_TAR_URL="http://ftp.gnu.org/gnu/diffutils/diffutils-3.3.tar.xz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
