SRC_TAR_URL="http://ftp.gnu.org/gnu/bash/bash-4.3.30.tar.gz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot || return 1
	sudo ln -sf bash $SYSROOT/bin/sh
}
