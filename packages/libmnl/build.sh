SRC_TAR_URL="http://www.netfilter.org/projects/libmnl/files/libmnl-1.0.3.tar.bz2"

prepare () {
	./configure --host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr --enable-static=no
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
