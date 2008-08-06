TESTS = test-alias.sh test-fns.sh
check_DATA = shunit2

abs_srcdir=@abs_srcdir@
abs_builddir=@abs_builddir@

TESTS_ENVIRONMENT = \
  srcdir="$(abs_srcdir)" \
  builddir="$(abs_builddir)"

EXTRA_DIST = $(TESTS) $(check_DATA)


