SRC_TAR_URL="http://ftp.gnu.org/gnu/tar/tar-1.29.tar.xz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
