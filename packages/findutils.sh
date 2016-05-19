SRC_TAR_URL="http://ftp.gnu.org/gnu/findutils/findutils-4.6.0.tar.gz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
