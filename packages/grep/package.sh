SRC_TAR_URL="http://ftp.gnu.org/gnu/grep/grep-2.25.tar.xz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
