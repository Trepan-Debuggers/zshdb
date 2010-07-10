# -*- shell-script -*-
# gdb-like "info files" debugger command
#
#   Copyright (C) 2010 Rocky Bernstein rocky@gnu.org
#
#   bashdb is free software; you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2, or (at your option) any later
#   version.
#
#   bashdb is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#   
#   You should have received a copy of the GNU General Public License along
#   with bashdb; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.

_Dbg_do_info_files() {
    _Dbg_msg "Source files which we have recorded info about:"
    unsetopt ksharrays
    for file in "${(ki)_Dbg_file2canonic}" ; do
	typeset -i lines=$(_Dbg_get_maxline "$file")
	typeset canonic_file
	canonic_file="${_Dbg_file2canonic[$file]}"
	if (( _Dbg_basename_only )) ; then 
	    # Do the same with canonic_file ?
	    file=${file##*/}
	    canonic_file=${canonic_file##*/}
	fi
	_Dbg_msg "  ${file}: ${canonic_file}, $lines lines"
    done
    setopt ksharrays
    return 0
}
