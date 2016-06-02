SRC_TAR_URL="http://download.savannah.gnu.org/releases/sysvinit/sysvinit-2.88dsf.tar.bz2"

prepare () {
	return 0
}

build () {
	cd src
	make CC=${CROSS_COMPILE}gcc
}

install () {
	sudo make ROOT="$SYSROOT" install || return 1
	sudo cp $PKG_DIR/inittab "$SYSROOT/etc/"
}
