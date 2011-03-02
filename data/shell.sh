# -*- shell-script -*-
# shell.sh - helper routines for 'shell' debugger command
#
#   Copyright (C) 2011 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

trap '_Dbg_write_saved_vars' EXIT
typeset -a _Dbg_save_vars

# _Dbg_tmpdir='/tmp'
# _Dbg_restore_info="${_Dbg_tmpdir}/${_Dbg_debugger_name}_restore_$$"
typeset -a _Dbg_save_vars; _Dbg_save_vars=()

# User level routine which should be called to mark which 
# variables should persist. 
save_vars() {
    _Dbg_save_vars+=($@)
}

_Dbg_write_saved_vars() {
    typeset param
    for param in "${_Dbg_save_vars[@]}" ; do 
	# FIXME chould check if var is an assoc array.
	case $parameters[$param] in
	    *assoc*)
            print -- "$param=( ${(P@kvqq)param} )";;
	    *array*)
            print -- "$param=( ${(P@qq)param} )";;
	    *scalar*)
            print -- "$param=${(P@qq)param}";;
	esac
    done > $_Dbg_restore_info
}
