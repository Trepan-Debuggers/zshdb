pkgdatadir        = ${datadir}/@PACKAGE@/lib
pkgdata_DATA =      	\
	action.sh    	\
	alias.sh    	\
	break.sh    	\
	columns.sh  	\
	display.sh  	\
	dbg-call.sh  	\
	file.sh  	\
	filecache.sh  	\
	fns.sh  	\
	frame.sh        \
	gdb.sh  	\
	help.sh    	\
	hist.sh    	\
	hook.sh		\
	info.sh		\
	journal.sh  	\
	list.sh  	\
	msg.sh  	\
	processor.sh  	\
	run.sh    	\
	save-restore.sh	\
	set-d-vars.sh   \
	setshow.sh      \
	shell.sh        \
	sort.sh 	\
	term-highlight.py \
	tty.sh          \
	validate.sh

install-data-hook: 
	chmod +x $(DESTDIR)$(pkgdatadir)/term-highlight.py

EXTRA_DIST = $(pkgdata_DATA)
MOSTLYCLEANFILES = *.orig *.rej
