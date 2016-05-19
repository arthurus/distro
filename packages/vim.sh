SRC_TAR_URL="ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2"

prepare () {
	vim_cv_toupper_broken=no \
	vim_cv_terminfo=yes \
	vim_cv_tty_group=world \
	vim_cv_getcwd_broken=no \
	vim_cv_stat_ignores_slash=yes \
	vim_cv_memmove_handles_overlap=yes \
	./configure $CONFIG_SHARED --with-tlib=ncurses
}

build () {
	make -j`nproc`
}

install () {
	install_to_sysroot
}
