SRC_TAR_URL="http://download-mirror.savannah.gnu.org/releases/libpipeline/libpipeline-1.4.1.tar.gz"

prepare () {
	./configure --host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
