dnl Configure script for Shell debugger
define(DEBUGGER, zshdb)
define(POSIXSHELL, zsh)
AC_INIT([zshdb],[1.1.2],[https://github.com/rocky/zshdb/issues])
AM_MAINTAINER_MODE
AM_INIT_AUTOMAKE([foreign])

AC_CONFIG_SRCDIR(DEBUGGER.in)
if test x$srcdir = x ; then
  srcdir=$ac_pwd
fi

# List of output variables produced by this configure script
#
AC_SUBST(DIFF)
AC_SUBST(DIFF_OPTS)
AC_PROG_GREP

CMDLINE_INVOKED='0 == ${#funcfiletrace[@]}'
AC_SUBST(CMDLINE_INVOKED)

# We need a GNU sed and the below allows us to use @SED@ in
# the integration tests programs.
AC_PROG_SED

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

AC_MSG_CHECKING([Checking whether $SH_PROG is compatible with DEBUGGER])
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

AC_CONFIG_FILES([ \
	Makefile                  \
	command/Makefile          \
	command/info_sub/Makefile \
	command/set_sub/Makefile  \
	command/show_sub/Makefile \
	data/Makefile             \
	doc/Makefile              \
	dbg-trace.sh              \
	lib/Makefile              \
	test/Makefile             \
	test/data/Makefile        \
	test/example/Makefile     \
	test/integration/Makefile \
	test/integration/check-common.sh \
	test/unit/Makefile        \
	test/zsh/Makefile         \
	])

AC_CONFIG_FILES(DEBUGGER, [chmod +x DEBUGGER])
AC_CONFIG_FILES([test/example/bug-args.sh],
                [chmod +x test/example/bug-args.sh])
AC_CONFIG_FILES([test/example/hanoi.sh],
                [chmod +x test/example/hanoi.sh])
AC_CONFIG_FILES([test/example/restart.sh],
                [chmod +x test/example/restart.sh])
AC_CONFIG_FILES([test/example/skip.sh],
                [chmod +x test/example/skip.sh])

AC_CONFIG_FILES([test/integration/test-action],
                [chmod +x test/integration/test-action])
AC_CONFIG_FILES([test/integration/test-brkpt1],
                [chmod +x test/integration/test-brkpt1])
AC_CONFIG_FILES([test/integration/test-bug-args],
                [chmod +x test/integration/test-bug-args])
AC_CONFIG_FILES([test/integration/test-bug-delete],
                [chmod +x test/integration/test-bug-delete])
AC_CONFIG_FILES([test/integration/test-bug-errexit],
                [chmod +x test/integration/test-bug-errexit])
AC_CONFIG_FILES([test/integration/test-bugIFS],
                [chmod +x test/integration/test-bugIFS])
AC_CONFIG_FILES([test/integration/test-bugIFS2],
                [chmod +x test/integration/test-bugIFS2])
AC_CONFIG_FILES([test/integration/test-bug-ksharrays],
                [chmod +x test/integration/test-bug-ksharrays])
AC_CONFIG_FILES([test/integration/test-condition],
                [chmod +x test/integration/test-condition])
AC_CONFIG_FILES([test/integration/test-debug],
                [chmod +x test/integration/test-debug])
AC_CONFIG_FILES([test/integration/test-delete],
                [chmod +x test/integration/test-delete])
AC_CONFIG_FILES([test/integration/test-display],
                [chmod +x test/integration/test-display])
AC_CONFIG_FILES([test/integration/test-enable],
                [chmod +x test/integration/test-enable])
AC_CONFIG_FILES([test/integration/test-examine],
                [chmod +x test/integration/test-examine])
AC_CONFIG_FILES([test/integration/test-export],
	        [chmod +x test/integration/test-export])
AC_CONFIG_FILES([test/integration/test-file-with-spaces],
                [chmod +x test/integration/test-file-with-spaces])
AC_CONFIG_FILES([test/integration/test-frame],
                [chmod +x test/integration/test-frame])
AC_CONFIG_FILES([test/integration/test-list],
                [chmod +x test/integration/test-list])
AC_CONFIG_FILES([test/integration/test-multi],
                [chmod +x test/integration/test-multi])
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

AC_CONFIG_FILES([test/unit/test-action.sh], [chmod +x test/unit/test-action.sh])
AC_CONFIG_FILES([test/unit/test-alias.sh],  [chmod +x test/unit/test-alias.sh])
AC_CONFIG_FILES([test/unit/test-break.sh],  [chmod +x test/unit/test-break.sh])
AC_CONFIG_FILES([test/unit/test-columns.sh],
                [chmod +x test/unit/test-columns.sh])
AC_CONFIG_FILES([test/unit/test-cmd-complete.sh],
                [chmod +x test/unit/test-cmd-complete.sh])
AC_CONFIG_FILES([test/unit/test-cmd-info-variables.sh],
                [chmod +x test/unit/test-cmd-info-variables.sh])
AC_CONFIG_FILES([test/unit/test-dbg-opts.sh],
                [chmod +x test/unit/test-dbg-opts.sh])
AC_CONFIG_FILES([test/unit/test-examine.sh],
		[chmod +x test/unit/test-examine.sh])
AC_CONFIG_FILES([test/unit/test-file.sh],
	        [chmod +x test/unit/test-file.sh])
AC_CONFIG_FILES([test/unit/test-filecache.sh],
	        [chmod +x test/unit/test-filecache.sh])
AC_CONFIG_FILES([test/unit/test-get-sourceline.sh],
		[chmod +x test/unit/test-get-sourceline.sh])
AC_CONFIG_FILES([test/unit/test-fns.sh],   [chmod +x test/unit/test-fns.sh])
AC_CONFIG_FILES([test/unit/test-frame.sh], [chmod +x test/unit/test-frame.sh])
AC_CONFIG_FILES([test/unit/test-journal.sh],
	        [chmod +x test/unit/test-journal.sh])
AC_CONFIG_FILES([test/unit/test-lib-eval.sh],
		[chmod +x test/unit/test-lib-eval.sh])
AC_CONFIG_FILES([test/unit/test-lib-shell.sh],
	        [chmod +x test/unit/test-lib-shell.sh])
AC_CONFIG_FILES([test/unit/test-msg.sh],
	        [chmod +x test/unit/test-msg.sh])
AC_CONFIG_FILES([test/unit/test-pre.sh],   [chmod +x test/unit/test-pre.sh])
AC_CONFIG_FILES([test/unit/test-run.sh],   [chmod +x test/unit/test-run.sh])
AC_CONFIG_FILES([test/unit/test-save-restore.sh],
		[chmod +x test/unit/test-save-restore.sh])
AC_CONFIG_FILES([test/unit/test-setshow.sh],
                [chmod +x test/unit/test-setshow.sh])
AC_CONFIG_FILES([test/unit/test-sort.sh],
		[chmod +x test/unit/test-sort.sh])
AC_CONFIG_FILES([test/unit/test-tty.sh],
		[chmod +x test/unit/test-tty.sh])
AC_CONFIG_FILES([test/unit/test-validate.sh],
		[chmod +x test/unit/test-validate.sh])

AC_OUTPUT
