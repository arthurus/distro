SRC_TAR_URL="https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.43/e2fsprogs-1.43.tar.xz"

prepare () {
	./configure $CONFIG_SHARED --enable-symlink-install --enable-relative-symlinks --enable-symlink-build --disable-fsck
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
