SRC_TAR_URL="http://www.linuxfromscratch.org/lfs/downloads/development/lfs-bootscripts-20150222.tar.bz2"

prepare () {
	patch -p1 < $PKG_DIR/fix.patch
}

build () {
	return 0
}

install () {
	sudo -E make DESTDIR=$SYSROOT files || return 1
	sudo $HOSTTOOLS_DIR/insserv -c $HOSTTOOLS_DIR/insserv.conf -p $SYSROOT/etc/init.d $SYSROOT/etc/init.d/*
}
