prepare () {
	return 0
}

build () {
	return 0
}

install () {
	sudo cp -r $PKG_DIR/etc "$SYSROOT" || return 1
}
