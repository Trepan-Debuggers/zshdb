dnl Configure script for Shell debugger
define(DEBUGGER, zshdb)
define(POSIXSHELL, zsh)
AC_INIT([zshdb],[0.03git],[rocky@gnu.org])
AM_PATH_LISPDIR
AM_MAINTAINER_MODE
AM_INIT_AUTOMAKE([no-define])

AC_CONFIG_SRCDIR(DEBUGGER.in)
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
AC_ARG_WITH(POSIXSHELL, AC_HELP_STRING([--with-POSIXSHELL], 
		  [location of POSIXSHELL program]), SH_PROG=$withval)

if test "$SH_PROG" = "yes" || test "$SH_PROG" = "no" || test -z "$SH_PROG"
then
  AC_PATH_PROG(SH_PROG, zsh, no)
fi

if test "$SH_PROG" = no; then
  AC_MSG_ERROR([I didn't find the] POSIXSHELL [executable.\
  You might want to use the] --with-POSIXSHELL [option.])
fi

AC_MSG_CHECKING([Checking whether $SH_PROG is compatible with zshdb])
if ! (cd ${srcdir}/test/zsh && $SH_PROG ./ok4zshdb.sh) ; then
  AC_MSG_RESULT([no dice :-(])
  AC_MSG_ERROR([You might want to retry with another POSIXSHELL using the --with-POSIXSHELL option.])
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

pkgdatadir=$datadir/DEBUGGER
AC_SUBST_DIR(PKGDATADIR, $pkgdatadir)

AM_MISSING_PROG(GIT2CL, git2cl, $missing_dir)
AC_PROG_LN_S
AC_PATH_PROG(RM, rm, true)

AC_PATH_PROG(EMACS, emacs, no)
if test x$EMACS != xno ; then
  $EMACS -batch -q -no-site-file -eval \
  '(if (<= emacs-major-version 21)
     (progn
       (error "You need GNU Emacs 22 or better for GNU Emacs support.")
       (kill-emacs 1)
     ))'
  if test $? -ne 0 ; then
    EMACS=no
  fi
fi

AM_CONDITIONAL(INSTALL_EMACS_LISP, 
	       [test "x$lispdir" != "x" -a "x$EMACS" != "xno"])

AC_CONFIG_FILES([ \
	Makefile \
	command/Makefile \
	doc/Makefile \
	dbg-trace.sh \
	emacs/Makefile \
	emacs/dbg-test.el \
	lib/Makefile \
	test/Makefile \
	test/data/Makefile \
	test/example/Makefile \
	test/integration/Makefile \
	test/integration/check-common.sh \
	test/unit/Makefile \
	test/zsh/Makefile \
	])

AC_CONFIG_FILES([zshdb], [chmod +x DEBUGGER])
AC_CONFIG_FILES([test/example/hanoi.sh], 
                [chmod +x test/example/hanoi.sh])

AC_CONFIG_FILES([test/integration/test-brkpt1], 
                [chmod +x test/integration/test-brkpt1])
AC_CONFIG_FILES([test/integration/test-bug-args], 
                [chmod +x test/integration/test-bug-args])
AC_CONFIG_FILES([test/integration/test-bug-errexit], 
                [chmod +x test/integration/test-bug-errexit])
AC_CONFIG_FILES([test/integration/test-bugIFS], 
                [chmod +x test/integration/test-bugIFS])
AC_CONFIG_FILES([test/integration/test-bug-ksharrays], 
                [chmod +x test/integration/test-bug-ksharrays])
AC_CONFIG_FILES([test/integration/test-condition], 
                [chmod +x test/integration/test-condition])
AC_CONFIG_FILES([test/integration/test-delete], 
                [chmod +x test/integration/test-delete])
AC_CONFIG_FILES([test/integration/test-enable], 
                [chmod +x test/integration/test-enable])
AC_CONFIG_FILES([test/integration/test-examine], 
                [chmod +x test/integration/test-examine])
AC_CONFIG_FILES([test/integration/test-frame], 
                [chmod +x test/integration/test-frame])
AC_CONFIG_FILES([test/integration/test-list], 
                [chmod +x test/integration/test-list])
AC_CONFIG_FILES([test/integration/test-next], 
                [chmod +x test/integration/test-next])
AC_CONFIG_FILES([test/integration/test-opts], 
                [chmod +x test/integration/test-opts])
AC_CONFIG_FILES([test/integration/test-restart], 
                [chmod +x test/integration/test-restart])
AC_CONFIG_FILES([test/integration/test-setshow], 
                [chmod +x test/integration/test-setshow])
AC_CONFIG_FILES([test/integration/test-skip], 
                [chmod +x test/integration/test-skip])
AC_CONFIG_FILES([test/integration/test-step], 
                [chmod +x test/integration/test-step])
AC_CONFIG_FILES([test/integration/test-subshell], 
                [chmod +x test/integration/test-subshell])
AC_CONFIG_FILES([test/integration/test-tbreak], 
                [chmod +x test/integration/test-tbreak])

AC_CONFIG_FILES([test/unit/test-alias.sh], [chmod +x test/unit/test-alias.sh])
AC_CONFIG_FILES([test/unit/test-break.sh], [chmod +x test/unit/test-break.sh])
AC_CONFIG_FILES([test/unit/test-columns.sh], 
                [chmod +x test/unit/test-columns.sh])
AC_CONFIG_FILES([test/unit/test-dbg-opts.sh], 
                [chmod +x test/unit/test-dbg-opts.sh])
AC_CONFIG_FILES([test/unit/test-examine.sh],   
		[chmod +x test/unit/test-examine.sh])
AC_CONFIG_FILES([test/unit/test-file.sh],
	        [chmod +x test/unit/test-file.sh])
AC_CONFIG_FILES([test/unit/test-filecache.sh],
	        [chmod +x test/unit/test-filecache.sh])
AC_CONFIG_FILES([test/unit/test-fns.sh],   [chmod +x test/unit/test-fns.sh])
AC_CONFIG_FILES([test/unit/test-frame.sh], [chmod +x test/unit/test-frame.sh])
AC_CONFIG_FILES([test/unit/test-journal.sh],
	        [chmod +x test/unit/test-journal.sh])
AC_CONFIG_FILES([test/unit/test-msg.sh],
	        [chmod +x test/unit/test-msg.sh])
AC_CONFIG_FILES([test/unit/test-pre.sh],   [chmod +x test/unit/test-pre.sh])
AC_CONFIG_FILES([test/unit/test-run.sh],   [chmod +x test/unit/test-run.sh])
AC_CONFIG_FILES([test/unit/test-save-restore.sh],
		[chmod +x test/unit/test-save-restore.sh])
AC_CONFIG_FILES([test/unit/test-sort.sh],
		[chmod +x test/unit/test-sort.sh])
AC_CONFIG_FILES([test/unit/test-tty.sh],
		[chmod +x test/unit/test-tty.sh])

AC_OUTPUT
