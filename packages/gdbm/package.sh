SRC_TAR_URL="http://ftp.gnu.org/gnu/gdbm/gdbm-1.12.tar.gz"

prepare () {
	./configure --host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
