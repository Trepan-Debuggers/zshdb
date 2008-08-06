AC_INIT([zshdb],[0.01],[rocky@gnu.org])
AM_PATH_LISPDIR
AM_MAINTAINER_MODE
AM_INIT_AUTOMAKE([no-define])

## --with-zsh can be used to tell the zshdb script and the regression
## test which bash to run. It can be omitted too in which case we'll
## look for a zsh binary.
AC_ARG_WITH(zsh, AC_HELP_STRING([--with-zsh], 
		  [location of zsh program]), ZSH_PROG=$withval)

if test "$ZSH_PROG" = "yes" || test "$ZSH_PROG" = "no" || test -z "$ZSH_PROG"
then
  AC_PATH_PROG(ZSH_PROG, zsh, no)
fi

AM_CONDITIONAL(INSTALL_EMACS_LISP, test "x$lispdir" != "x")

AC_CONFIG_FILES([Makefile \
	command/Makefile \
	emacs/Makefile \
	emacs/zshdb-test.el \
	lib/Makefile \
	test/Makefile \
	test/unit/Makefile])

AC_CONFIG_FILES([zshdb], [chmod +x zshdb])
AC_CONFIG_FILES([test/unit/test-alias.sh], [chmod +x test/unit/test-alias.sh])
AC_CONFIG_FILES([test/unit/test-fns.sh], [chmod +x test/unit/test-fns.sh])

AC_OUTPUT
