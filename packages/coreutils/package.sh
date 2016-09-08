SRC_TAR_URL="http://ftp.gnu.org/gnu/coreutils/coreutils-8.25.tar.xz"

make_native_man () {
	./configure || return 1
	make -j`nproc` || return 1
	mkdir man_native && cp man/*.1 man_native || return 1
	make distclean
}

prepare () {
	make_native_man || return 1
	patch -i $PKG_DIR/Makefile.in.patch || return 1
	./configure $CONFIG_SHARED || return 1
	cp man_native/* man
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
