SRC_TAR_URL="http://download.savannah.gnu.org/releases/sysvinit/insserv-1.14.0.tar.bz2"

prepare () {
	patch < $PKG_DIR/build.patch || return 1
	make ISSUSE='' || return 1
	cp insserv $HOSTTOOLS_DIR || return 1
	cp insserv.conf $HOSTTOOLS_DIR || return 1
}

build () {
	make CC=${CROSS_COMPILE}gcc ISSUSE=''
}

install () {
	sudo -E make CC=${CROSS_COMPILE}gcc ISSUSE='' DESTDIR="$SYSROOT" install || return 1
}
