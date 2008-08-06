SUBDIRS = command emacs lib test

pkgdata_DATA = dbg-pre.inc main.inc opts.inc

EXTRA_DIST = $(pkgdata_DATA)

# cvs2cl
MAINTAINERCLEANFILES = ChangeLog

if MAINTAINER_MODE

.PHONY: ChangeLog
# ChangeLog:
# 	$(CVS2CL) -W 450 --header $(srcdir)/cvs2cl_header --utc -w -I ChangeLog --usermap $(srcdir)/cvs2cl_usermap -P 

# ACLOCAL_AMFLAGS=-I .

endif



