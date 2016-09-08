SRC_TAR_URL="http://roy.marples.name/downloads/dhcpcd/dhcpcd-6.11.0.tar.xz"

prepare () {
	./configure --host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr --bindir=/bin --sbindir=/sbin --sysconfigdir=/etc --libdir=/lib --localstatedir=/var --libexecdir=/lib/dhcpcd
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot || return 1
	sudo cp -r "$PKG_DIR/services" "$SYSROOT/lib/"
}
