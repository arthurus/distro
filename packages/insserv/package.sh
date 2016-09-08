SRC_TAR_URL="http://download.savannah.gnu.org/releases/sysvinit/insserv-1.14.0.tar.bz2"

prepare () {
	patch < $PKG_DIR/build.patch
}

build () {
	make CC=${CROSS_COMPILE}gcc ISSUSE=''
}

install () {
	sudo -E make CC=${CROSS_COMPILE}gcc ISSUSE='' DESTDIR="$SYSROOT" install || return 1
}
