SRC_TAR_URL="http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.4.0.tar.gz"

prepare () {
	./configure --host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
