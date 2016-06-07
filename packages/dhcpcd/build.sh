SRC_TAR_URL="http://roy.marples.name/downloads/dhcpcd/dhcpcd-6.11.0.tar.xz"

prepare () {
	./configure --host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr --sysconfdir=/etc --localstatedir=/var
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
