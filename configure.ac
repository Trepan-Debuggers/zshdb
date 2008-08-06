AC_INIT([zshdb],[0.01],[rocky@gnu.org])
AM_PATH_LISPDIR
AM_MAINTAINER_MODE
AM_INIT_AUTOMAKE([no-define])

AM_CONDITIONAL(INSTALL_EMACS_LISP, test "x$lispdir" != "x")

AC_CONFIG_FILES([Makefile \
	command/Makefile \
	emacs/Makefile \
	emacs/zshdb-test.el \
	lib/Makefile \
	test/Makefile \
	test/unit/Makefile])

AC_OUTPUT
