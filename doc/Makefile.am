EXT=1
man1_MANS = @PACKAGE@.$(EXT)

EXTRA_DIST = $(man1_MANS) @PACKAGE@-man.pod

all: $(INFO_DEPS) $(man1_MANS) html 

$(man1_MANS): @PACKAGE@-man.pod
	pod2man --name=@PACKAGE@ --release=$(PACKAGE_VERSION) --section=$(EXT) $(srcdir)/@PACKAGE@-man.pod >$@

MOSTLYCLEANFILES = $(man1_MANS)
