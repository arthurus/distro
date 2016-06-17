SRC_TAR_URL="http://ftp.gnu.org/gnu/patch/patch-2.7.tar.xz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
