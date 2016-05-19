SRC_TAR_URL="http://ftp.gnu.org/gnu/coreutils/coreutils-8.25.tar.xz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	# TODO: man pages
	cd man && for file in `ls | sed 's/\.x//'`; do touch $file.1; done
	cd ..
	make -j`nproc`
	# again because of error...
	cd man && for file in `ls | sed 's/\.x//'`; do touch $file.1; done
	cd ..
	make -j`nproc`
}

install () {
	install_to_sysroot
}
