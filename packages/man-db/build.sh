SRC_TAR_URL="http://download.savannah.gnu.org/releases/man-db/man-db-2.7.5.tar.xz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot || return 1
	sudo mkdir -p $SYSROOT/var/cache/man || return 1
	sudo chown man $SYSROOT/var/cache/man || return 1
}
