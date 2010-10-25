# -*- shell-script -*-
# "set tracecommands" debugger command
#
#   Copyright (C) 2010 Rocky Bernstein rocky@gnu.org
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

_Dbg_do_set_trace_commands() {
    case $1 in 
	1 )
	    _Dbg_write_journal_eval "_Dbg_set_trace_commands=on"
	    ;;
	0 )
	    _Dbg_write_journal_eval "_Dbg_set_trace_commands=off"
	    ;;
	on | off )
	    _Dbg_write_journal_eval "_Dbg_set_trace_commands=$1"
	    ;;
	* )
	    _Dbg_errmsg "\"on\", \"off\" expected."
	    return 1
    esac
    return 0
}
