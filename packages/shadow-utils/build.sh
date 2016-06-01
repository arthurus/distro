SRC_TAR_URL="https://github.com/shadow-maint/shadow/archive/4.3.0.tar.gz"

prepare () {
	autoreconf -v -f --install
	./configure $CONFIG_SHARED --enable-man
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
