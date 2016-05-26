SRC_GIT_URL="git://git.code.sf.net/p/net-tools/code"

CONFIG_MAKE="
HAVE_AFUNIX=1
HAVE_AFINET=1
HAVE_AFINET6=1
HAVE_HWETHER=1
HAVE_HWPPP=1
HAVE_FW_MASQUERADE=1
HAVE_ARP_TOOLS=1
HAVE_HOSTNAME_TOOLS=1
HAVE_HOSTNAME_SYMLINKS=1
HAVE_IP_TOOLS=1
"

CONFIG_H="
#define I18N 0
#define HAVE_AFUNIX 1
#define HAVE_AFINET 1
#define HAVE_AFINET6 1
#define HAVE_AFIPX 0
#define HAVE_AFATALK 0
#define HAVE_AFAX25 0
#define HAVE_AFNETROM 0
#define HAVE_AFROSE 0
#define HAVE_AFX25 0
#define HAVE_AFECONET 0
#define HAVE_AFDECnet 0
#define HAVE_AFASH 0
#define HAVE_AFBLUETOOTH 0
#define HAVE_HWETHER 1
#define HAVE_HWARC 0
#define HAVE_HWSLIP 0
#define HAVE_HWPPP 0
#define HAVE_HWTUNNEL 0
#define HAVE_HWSTRIP 0
#define HAVE_HWTR 0
#define HAVE_HWAX25 0
#define HAVE_HWROSE 0
#define HAVE_HWNETROM 0
#define HAVE_HWX25 0
#define HAVE_HWFR 0
#define HAVE_HWSIT 0
#define HAVE_HWFDDI 0
#define HAVE_HWHIPPI 0
#define HAVE_HWASH 0
#define HAVE_HWHDLCLAPB 0
#define HAVE_HWIRDA 0
#define HAVE_HWEC 0
#define HAVE_HWEUI64 0
#define HAVE_HWIB 0
#define HAVE_FW_MASQUERADE 1
#define HAVE_ARP_TOOLS 1
#define HAVE_HOSTNAME_TOOLS 1
#define HAVE_HOSTNAME_SYMLINKS 1
#define HAVE_IP_TOOLS 0
#define HAVE_MII 0
#define HAVE_PLIP_TOOLS 0
#define HAVE_SERIAL_TOOLS 0
#define HAVE_SELINUX 0
"

prepare () {
	git pull || return 1
	make clobber || return 1
	echo "$CONFIG_MAKE" > config.make
	echo "$CONFIG_H" > config.h
}

build () {
	make -j`nproc` CC=$TARGET-gcc
}

install () {
	install_to_sysroot
}
