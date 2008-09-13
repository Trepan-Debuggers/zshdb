TESTS = \
	test-brkpt1        \
	test-bug-args      \
	test-bugIFS        \
	test-bug-errexit   \
	test-delete        \
	test-enable        \
	test-frame         \
	test-next          \
	test-opts          \
	test-setshow       \
	test-skip	   \
	test-step

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


