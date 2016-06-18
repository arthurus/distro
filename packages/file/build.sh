SRC_TAR_URL="ftp://ftp.astron.com/pub/file/file-5.28.tar.gz"

make_local () {
	TMP_DIR=`mktemp -d`
	./configure --prefix=/usr || return 1
	make || return 1
	make DESTDIR="$TMP_DIR" install || return 1
	echo "LD_LIBRARY_PATH=$TMP_DIR/usr/lib64/ $TMP_DIR/usr/bin/file -m $TMP_DIR/usr/share/misc/magic.mgc \$@" > ./file_local
	chmod +x ./file_local
}

prepare () {
	make_local || return 1
	./configure $CONFIG_SHARED
}

build () {
	make -j`nproc` FILE_COMPILE=`pwd`/file_local || return 1
	[ -n "$TMP_DIR" ] && rm -rf "$TMP_DIR"
}

install () {
	install_to_sysroot
}
