TESTS = \
	test-action.sh       \
	test-alias.sh        \
	test-break.sh        \
	test-columns.sh      \
	test-dbg-opts.sh     \
	test-examine.sh      \
	test-eval.sh         \
	test-file.sh         \
	test-filecache.sh    \
	test-fns.sh          \
	test-frame.sh        \
        test-get-sourceline.sh \
	test-journal.sh      \
        test-lib-shell.sh    \
	test-msg.sh          \
	test-pre.sh          \
	test-run.sh          \
	test-save-restore.sh \
	test-setshow.sh      \
	test-sort.sh         \
	test-tty.sh 	     \
	test-validate.sh

check_DATA = shunit2

abs_srcdir=@abs_srcdir@
abs_builddir=@abs_builddir@

TESTS_ENVIRONMENT = \
  srcdir="$(abs_srcdir)" \
  builddir="$(abs_builddir)"

EXTRA_DIST = $(TESTS) $(check_DATA) \
	test-action.sh.in           \
	test-alias.sh.in            \
	test-break.sh.in            \
	test-columns.sh.in          \
	test-dbg-opts.sh.in         \
	test-eval.sh.in             \
	test-examine.sh.in          \
	test-file.sh.in             \
	test-filecache.sh.in        \
	test-fns.sh.in              \
	test-frame.sh.in            \
        test-get-sourceline.sh.in   \
	test-journal.sh.in          \
        test-lib-shell.sh.in        \
	test-msg.sh.in              \
	test-pre.sh.in              \
	test-run.sh.in              \
	test-save-restore.sh.in     \
	test-setshow.sh.in          \
	test-sort.sh.in             \
	test-tty.sh.in              \
	test-validate.sh.in

test: check
test-unit: check
