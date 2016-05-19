SRC_GIT_URL="https://github.com/raspberrypi/linux.git"

prepare () {
	git clean -df || return 1
	git reset --hard HEAD || return 1
	git checkout origin/rpi-4.1.y || return 1
	git branch -D build || return 1
	git checkout -b build || return 1
	make distclean || return 1
	make bcmrpi_defconfig || return 1
}

build () {
        make -j`nproc`
}

install () {
        sudo -E make INSTALL_MOD_PATH=$SYSROOT modules_install
}
