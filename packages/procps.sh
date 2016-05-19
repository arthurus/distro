SRC_TAR_URL="http://downloads.sourceforge.net/project/procps-ng/Production/procps-ng-3.3.11.tar.xz"

prepare () {
	./autogen.sh
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes \
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
