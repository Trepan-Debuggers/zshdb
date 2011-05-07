pkgdatadir   = ${datadir}/@PACKAGE@/lib
pkgdata_DATA = $(wildcard *.sh) term-highlight.py

install-data-hook: 
	chmod +x $(DESTDIR)$(pkgdatadir)/term-highlight.py

EXTRA_DIST = $(pkgdata_DATA)
MOSTLYCLEANFILES = *.orig *.rej
