SRC_TAR_URL="http://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz"

prepare () {
	./configure $CONFIG_SHARED --with-shared --without-debug --without-normal --enable-pc-files
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
