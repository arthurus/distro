SRC_GIT_URL="git://git.denx.de/u-boot.git"

UBOOT_BOOT_SCR="
setenv bootargs dwc_otg.lpm_enable=0 console=tty0 console=ttyAMA0,115200 root=/dev/mmcblk0p$ROOT_PART_NO rw rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait
setenv fdtfile bcm2708-rpi-b-plus.dtb
mmc dev 0
ext4load mmc 0:$ROOT_PART_NO \${kernel_addr_r} /boot/vmlinuz
fatload mmc 0:$BOOT_PART_NO \${fdt_addr_r} \${fdtfile}
bootz \${kernel_addr_r} - \${fdt_addr_r}
"

prepare () {
	git clean -df || return 1
	git reset --hard HEAD || return 1
	git pull || return 1
	make distclean || return 1
	make rpi_defconfig || return 1
}

build () {
	make -j`nproc`
}

install () {
	cp u-boot.bin "$BOOTPART_DIR" || return 1
	echo "$UBOOT_BOOT_SCR" > boot.scr || return 1
	./tools/mkimage -A arm -O linux -T script -C none -n boot.scr -d boot.scr boot.scr.uimg || return 1
	cp boot.scr.uimg "$BOOTPART_DIR" || return 1
}
