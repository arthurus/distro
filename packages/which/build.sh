SRC_TAR_URL="http://ftp.gnu.org/gnu/which/which-2.21.tar.gz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
