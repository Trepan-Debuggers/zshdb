TESTS = \
	test-brkpt1        \
	test-bug-args      \
	test-bugIFS        \
	test-bug-errexit   \
	test-bug-ksharrays \
	test-condition     \
	test-delete        \
	test-enable        \
	test-examine       \
	test-frame         \
	test-list          \
	test-next          \
	test-opts          \
	test-restart       \
	test-setshow       \
	test-skip	   \
	test-step	   \
	test-subshell	   \
	test-tbreak

check_DATA = check-common.sh

abs_srcdir=@abs_srcdir@
abs_builddir=@abs_builddir@

TESTS_ENVIRONMENT = \
  srcdir="$(abs_srcdir)" \
  builddir="$(abs_builddir)"

EXTRA_DIST = $(TESTS) $(check_DATA) \
	check-common.sh.in \
	lopts.tests        \
	sopts.tests

CLEANFILES = *.check

test: check
test-integration: check
