SRC_GIT_URL="https://github.com/raspberrypi/linux.git"

prepare () {
	git clean -df || return 1
	git reset --hard HEAD || return 1
	git fetch
	git checkout origin/rpi-4.4.y || return 1
	git branch -D build || return 1
	git checkout -b build || return 1
	make distclean || return 1
	#make bcmrpi_defconfig || return 1
	cp $PKG_DIR/config .config
}

build () {
	make -j`nproc`
}

install () {
	local release=`make kernelrelease` || return 1
	local img_name=`make image_name` || return 1
	local target_img_name=vmlinuz-$release

	sudo cp arch/arm/boot/$img_name "$SYSROOT/boot/$target_img_name" || return 1
	sudo ln -sf $target_img_name "$SYSROOT/boot/vmlinuz" || return 1
	sudo cp System.map "$SYSROOT/boot/System.map-$release" || return 1

	sudo -E make INSTALL_MOD_PATH="$SYSROOT" modules_install || return 1

	cp arch/arm/boot/dts/bcm2708-rpi-b-plus.dtb "$BOOTPART_DIR" || return 1

	mkdir "$BOOTPART_DIR/overlays"
	cp arch/arm/boot/dts/overlays/*.dtbo "$BOOTPART_DIR/overlays" || return 1
	cp arch/arm/boot/dts/overlays/README "$BOOTPART_DIR/overlays" || return 1
}
