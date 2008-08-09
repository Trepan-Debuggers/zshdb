SUBDIRS = command emacs lib test

pkgdata_DATA = dbg-pre.sh dbg-main.sh dbg-opts.sh

EXTRA_DIST = $(pkgdata_DATA)

# cvs2cl
MAINTAINERCLEANFILES = ChangeLog

if MAINTAINER_MODE

.PHONY: ChangeLog
ChangeLog:
	git log --pretty --numstat --summary | $(GIT2CL)

ACLOCAL_AMFLAGS=-I .

endif



