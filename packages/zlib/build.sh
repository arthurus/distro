SRC_TAR_URL="http://zlib.net/zlib-1.2.8.tar.gz"

prepare () {
	CHOST=$TARGET ./configure --prefix=/usr
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot || return 1
	sudo mv "$SYSROOT"/usr/lib/libz.so.* "$SYSROOT/lib/" || return 1
	sudo ln -sfv "../../lib/$(readlink $SYSROOT/usr/lib/libz.so)" "$SYSROOT/usr/lib/libz.so" || return 1
	
}
