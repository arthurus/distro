SRC_TAR_URL="http://ftp.gnu.org/gnu/sed/sed-4.2.2.tar.bz2"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
