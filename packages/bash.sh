SRC_TAR_URL="http://ftp.gnu.org/gnu/bash/bash-4.3.30.tar.gz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
	sudo ln -s bash $SYSROOT/bin/sh
}