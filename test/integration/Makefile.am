TESTS = \
	test-action        \
	test-brkpt1        \
	test-bug-args      \
	test-bug-delete	   \
	test-bugIFS        \
	test-bugIFS2       \
	test-bug-errexit   \
	test-bug-ksharrays \
	test-condition     \
	test-debug         \
	test-delete        \
	test-enable        \
	test-examine       \
	test-export        \
	test-examine       \
	test-frame         \
	test-list          \
	test-multi         \
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
  SHELL=@SH_PROG@   \
  SH=@SH_PROG@      \
  srcdir="$(abs_srcdir)" \
  builddir="$(abs_builddir)"

SOURCES=check-common.sh.in \
	test-action.in \
	test-brkpt1.in \
	test-bug-args.in \
	test-bug-delete.in \
	test-bug-errexit.in \
	test-bugIFS.in \
	test-bug-ksharrays.in \
	test-condition.in \
	test-debug.in \
	test-delete.in \
	test-display.in \
	test-enable.in \
	test-examine.in \
	test-file-with-spaces.in \
	test-frame.in \
	test-list.in \
	test-multi.in \
	test-next.in \
	test-opts.in \
	test-restart.in \
	test-setshow.in \
	test-skip.in \
	test-step.in \
	test-subshell.in \
	test-tbreak.in

EXTRA_DIST = $(TESTS) $(check_DATA) $(SOURCES) \
	README.md check-common.sh.in \
	lopts.tests        \
	sopts.tests

CLEANFILES = *.check

test: check
test-integration: check
