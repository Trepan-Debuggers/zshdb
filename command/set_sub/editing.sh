# -*- shell-script -*-
# "set editing" debugger command
#
#   Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add_sub set editing \
'Readline editing of command lines' 1

_Dbg_do_set_editing() {
    typeset onoff=${1:-'on'}
    case $onoff in 
	e | em | ema | emac | emacs ) 
	    _Dbg_edit='-e'
	    _Dbg_edit_style='emacs'
	    builtin bindkey -e 
	    ;;
	on | 1 ) 
	    _Dbg_edit='-e'
	    _Dbg_edit_style='emacs'
	    builtin bindkey -e
	    ;;
	off | 0 )
	    _Dbg_edit=''
	    return 0
	    ;;
	v | vi ) 
	    _Dbg_edit='-e'
	    _Dbg_edit_style='vi'
	    builtin bindkey -v 
	    ;;
	* )
	    _Dbg_errmsg '"on", "off", "vi", or "emacs" expected.'
	    return 1
    esac
    return 0
}
