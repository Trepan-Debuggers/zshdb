TESTS = \
	test-bug-args \
	test-bugIFS   \
	test-frame    \
	test-opts     \
	test-setshow

check_DATA = check-common.sh setshow.tests

abs_srcdir=@abs_srcdir@
abs_builddir=@abs_builddir@

TESTS_ENVIRONMENT = \
  srcdir="$(abs_srcdir)" \
  builddir="$(abs_builddir)"

EXTRA_DIST = $(TESTS) $(check_DATA) \
	check-common.sh.in



