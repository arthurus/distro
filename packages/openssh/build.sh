SRC_TAR_URL="http://ftp.icm.edu.pl/pub/OpenBSD/OpenSSH/portable/openssh-7.2p2.tar.gz"

prepare () {
	patch -i $PKG_DIR/Makefile.in.patch
	./configure --host=$TARGET --build=x86_64-pc-linux-gnu --prefix=/usr --sysconfdir=/etc/ssh --localstatedir=/var --disable-lastlog
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot || return 1
	sudo chown root:root $SYSROOT/var/empty || return 1
	sudo chmod 755 $SYSROOT/var/empty || return 1
	sudo install -m 754 $PKG_DIR/sshd $SYSROOT/etc/init.d/ || return 1
	sudo sed -i.bak 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' $SYSROOT/etc/ssh/sshd_config || return 1
	sudo rm $SYSROOT/etc/ssh/sshd_config.bak
}
