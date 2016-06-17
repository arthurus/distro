SRC_TAR_URL="http://ftp.gnu.org/gnu/gzip/gzip-1.8.tar.xz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
