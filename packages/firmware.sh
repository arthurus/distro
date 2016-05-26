SRC_GIT_URL="https://github.com/raspberrypi/firmware.git"

CONFIG_TXT="
kernel=u-boot.bin
boot_delay=0
dtoverlay=sdio,poll_once=off
"

prepare () {
	git pull || return 1
}

build () {
	return 0
}

install () {
	cp boot/bootcode.bin "$BOOTPART_DIR" || return 1
	cp boot/fixup*.dat "$BOOTPART_DIR" || return 1
	cp boot/start*.elf "$BOOTPART_DIR" || return 1
	sudo cp -r hardfp/opt/vc "$SYSROOT/opt"
	echo "$CONFIG_TXT" > "$BOOTPART_DIR/config.txt"
}
