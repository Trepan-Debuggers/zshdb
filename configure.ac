AC_INIT([zshdb],[0.01],[rocky@gnu.org])
AM_PATH_LISPDIR
AM_MAINTAINER_MODE
AM_INIT_AUTOMAKE([no-define])

AC_CONFIG_SRCDIR(zshdb.in)
if test x$srcdir = x ; then
  srcdir=$ac_pwd
fi

# List of output variables produced by this configure script
#
AC_SUBST(DIFF)
AC_SUBST(DIFF_OPTS)

## --with-zsh can be used to tell the zshdb script and the regression
## test which bash to run. It can be omitted too in which case we'll
## look for a zsh binary.
AC_ARG_WITH(zsh, AC_HELP_STRING([--with-zsh], 
		  [location of zsh program]), SH_PROG=$withval)

if test "$SH_PROG" = "yes" || test "$SH_PROG" = "no" || test -z "$SH_PROG"
then
  AC_PATH_PROG(SH_PROG, zsh, no)
fi

if test "$SH_PROG" = no; then
  AC_MSG_ERROR([I didn't find the zsh executable.\
  You might want to use the --with-zsh option.])
fi

AC_MSG_CHECKING([Checking whether $SH_PROG is compatible with zshdb])
if ! (cd ${srcdir}/test/zsh && $SH_PROG ./ok4zshdb.sh) ; then
  AC_MSG_RESULT([no dice :-(])
  AC_MSG_ERROR([You might want to retry with another zsh using the --with-zsh option.])
else
  AC_MSG_RESULT(yes!)
fi

dnl We use a diff in regression testing
AC_PATH_PROG(DIFF, diff, no)
DIFF_OPTS=

if test "$DIFF" = no ; then
   AC_PATH_PROG(DIFF, cmp, no)
else 
   dnl Try for GNU diff options.
  # MSDOG output uses \r\n rather than \n in tests
  for diff_opt in -w --unified ; do 
    if $DIFF $diff_opt . . > /dev/null 2>&1; then
      AC_MSG_RESULT([adding $diff_opt to diff in regression tests])
      DIFF_OPTS="$DIFF_OPTS $diff_opt"
    fi
  done
fi

# Get the fully expanded name of pkgdatadir. This is used in zshdb.in
# and dbg-main.sh.in and for installing debugger files.

pkgdatadir=$datadir/zshdb
AC_SUBST_DIR(PKGDATADIR, $pkgdatadir)

AM_MISSING_PROG(GIT2CL, git2cl, $missing_dir)
AC_PROG_LN_S
AC_PATH_PROG(RM, rm, true)

AC_PATH_PROG(EMACS, emacs, no)
if test x$EMACS = xno ; then
  emacs_lisp=no
else 
  $EMACS -batch -q -no-site-file -eval \
  '(if (not (and (= emacs-major-version 21) (<= emacs-minor-version 3))) (error "This gud is for Emacs 21.0 to 21.3."))'
  if test $? -ne 0 ; then
    emacs_lisp=no
  fi
fi

AM_CONDITIONAL(INSTALL_EMACS_LISP, test "x$lispdir" != "x")

AC_CONFIG_FILES([Makefile \
	command/Makefile \
	emacs/Makefile \
	emacs/zshdb-test.el \
	lib/Makefile \
	test/Makefile \
	test/data/Makefile \
	test/example/Makefile \
	test/integration/check-common.sh \
	test/integration/Makefile \
	test/unit/Makefile \
	test/zsh/Makefile \
	])

AC_CONFIG_FILES([zshdb], [chmod +x zshdb])
AC_CONFIG_FILES([test/unit/test-alias.sh], [chmod +x test/unit/test-alias.sh])
AC_CONFIG_FILES([test/unit/test-fns.sh],   [chmod +x test/unit/test-fns.sh])
AC_CONFIG_FILES([test/unit/test-run.sh],   [chmod +x test/unit/test-run.sh])
AC_CONFIG_FILES([test/unit/test-save-restore.sh],
		[chmod +x test/unit/test-save-restore.sh])

AC_OUTPUT
