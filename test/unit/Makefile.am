COMBINED_TESTS= \
	test-action.sh         \
	test-break.sh          \
	test-cmd-complete.sh   \
	test-columns.sh        \
	test-dbg-opts.sh       \
	test-lib-eval.sh       \
	test-examine.sh        \
	test-file.sh           \
	test-filecache.sh      \
	test-fns.sh            \
	test-frame.sh          \
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

test_sources = $(TESTS:=.in) $(COMBINED_TESTS::=.in)

EXTRA_DIST = helper.sh $(COMBINED_TESTS) $(TESTS) shunit2 $(test_sources)

check: combined-tests check-am
test: check
test-unit: check

combined-tests: $(COMBINED_TESTS)
	$(SH_PROG) $(abs_srcdir)/shunit2 $(COMBINED_TESTS)

check-short: $(COMBINED_TESTS)
	@$(SH_PROG) $(abs_srcdir)/shunit2 $(COMBINED_TESTS) | grep -v ^make
MOSTLYCLEANFILES = *.orig *.rej
