# -*- shell-script -*-
# "set showcommand" debugger command
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

# Sets whether or not to display command to be executed in debugger prompt.
# If yes, always show. If auto, show only if the same line is to be run
# but the command is different.
typeset _Dbg_set_show_command="auto"

_Dbg_do_set_showcommand() {
    case "$1" in 
	1 )
	    _Dbg_write_journal_eval "_Dbg_set_show_command=on"
	    ;;
	0 )
	    _Dbg_write_journal_eval "_Dbg_set_show_command=off"
	    ;;
	on | off | auto )
	    _Dbg_write_journal_eval "_Dbg_set_show_command=$1"
	    ;;
	* )
	    _Dbg_errmsg "\"on\", \"off\" or \"auto\" expected."
    esac
    return 0
}
