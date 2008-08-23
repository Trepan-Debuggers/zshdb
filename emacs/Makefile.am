#   Copyright (C) 2002, 2003, 2006, 2008 Rocky Bernstein rocky@gnu.org
#
#   zshdb is free software; you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2, or (at your option) any later
#   version.
#
#   zshdb is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#   
#   You should have received a copy of the GNU General Public License along
#   with zshdb; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.
#$Id: Makefile.am,v 1.7 2008/01/11 13:57:31 rockyb Exp $

check_DATA = dbg-test.el dbg-test.el.in elk-test.el
EXTRA_DIST = @PACKAGE@.el $(check_DATA)
ELCFILES  =  @PACKAGE@.elc
if INSTALL_EMACS_LISP
lisp_LISP = @PACKAGE@.el


check:
	$(EMACS) -batch -q -l $(top_builddir)/emacs/dbg-test.el $(srcdir)/elk-test.el
endif
test: check
