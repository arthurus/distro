SRC_TAR_URL="http://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz"

prepare () {
	patch -i $PKG_DIR/aclocal.m4.patch || return 1
	autoconf || return 1
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc` SHLIB_LIBS=-lncurses
}

install () {
	install_to_sysroot
}
