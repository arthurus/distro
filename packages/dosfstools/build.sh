SRC_TAR_URL="https://github.com/dosfstools/dosfstools/releases/download/v4.0/dosfstools-4.0.tar.xz"

prepare () {
	./configure $CONFIG_SHARED --enable-compat-symlinks
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
