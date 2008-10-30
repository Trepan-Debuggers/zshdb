TESTS = test-alias.sh        \
	test-columns.sh      \
	test-dbg-opts.sh     \
	test-file.sh         \
	test-filecache.sh    \
	test-fns.sh          \
	test-frame.sh        \
	test-journal.sh      \
	test-pre.sh          \
	test-run.sh          \
	test-save-restore.sh \
	test-sort.sh
check_DATA = shunit2

abs_srcdir=@abs_srcdir@
abs_builddir=@abs_builddir@

TESTS_ENVIRONMENT = \
  srcdir="$(abs_srcdir)" \
  builddir="$(abs_builddir)"

EXTRA_DIST = $(TESTS) $(check_DATA) \
	test-alias.sh.in            \
	test-columns.sh.in          \
	test-dbg-opts.sh.in         \
	test-file.sh.in             \
	test-filecache.sh.in        \
	test-fns.sh.in              \
	test-frame.sh.in            \
	test-journal.sh.in          \
	test-pre.sh.in              \
	test-run.sh.in              \
	test-save-restore.sh.in     \
	test-sort.sh.in

test: check
test-unit: check
