SRC_TAR_URL="http://ftp.gnu.org/gnu/less/less-481.tar.gz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
