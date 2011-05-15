COMBINED_TESTS= \
	test-action.sh         \
	test-break.sh          \
	test-cmd-complete.sh   \
	test-columns.sh        \
	test-dbg-opts.sh       \
	test-eval.sh           \
	test-examine.sh        \
	test-file.sh           \
	test-filecache.sh      \
	test-fns.sh            \
	test-get-sourceline.sh \
	test-journal.sh        \
	test-lib-shell.sh      \
	test-msg.sh            \
	test-pre.sh            \
	test-run.sh            \
	test-tty.sh

TESTS = \
	test-alias.sh        \
	test-save-restore.sh \
	test-setshow.sh      \
	test-sort.sh         \
	test-validate.sh

check_DATA = shunit2

abs_srcdir=@abs_srcdir@
abs_builddir=@abs_builddir@

TESTS_ENVIRONMENT = \
  srcdir="$(abs_srcdir)" \
  builddir="$(abs_builddir)"

EXTRA_DIST = $(COMBINED_TESTS) $(SINGLE_TESTS) $(check_DATA) \
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

check: combined_tests check-am
test: check
test-unit: check

combined_tests: $(COMBINED_TESTS)
	$(SH_PROG) $(abs_srcdir)/shunit2 $(COMBINED_TESTS)

MOSTLYCLEANFILES = *.orig *.rej
