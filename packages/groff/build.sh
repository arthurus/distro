SRC_TAR_URL="http://ftp.gnu.org/gnu/groff/groff-1.22.3.tar.gz"

prepare () {
	./configure $CONFIG_SHARED
}

build () {
	make TROFFBIN=troff GROFFBIN=groff GROFF_BIN_PATH=
}

install () {
	install_to_sysroot
}
