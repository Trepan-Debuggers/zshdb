EXT=1
man1_MANS = zshdb.$(EXT)

all: $(INFO_DEPS) $(man1_MANS) html 

$(man1_MANS): zshdb-man.pod
	pod2man --release=$(PACKAGE_VERSION) --section=$(EXT) $(srcdir)/zshdb-man.pod >$@
