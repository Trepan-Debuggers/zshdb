# -*- shell-script -*-
# gdb-like "info display" debugger command
#
#   Copyright (C) 2010-2011, 2014, 2016 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add_sub info display '
**info display**

Show all display expressions
' 1

# List display command(s)
_Dbg_do_info_display() {
    if [ ${#_Dbg_disp_exp[@]} != 0 ]; then
	typeset i=0
	_Dbg_msg "Auto-display statements now in effect:"
	_Dbg_msg "Num Enb Expression          "
	for (( i=0; i < _Dbg_disp_max; i++ )) ; do
	    if [ -n "${_Dbg_disp_exp[$i]}" ] ;then
		_Dbg_printf '%-3d %3d %s' \
		    $i ${_Dbg_disp_enable[$i]} "${_Dbg_disp_exp[$i]}"
	    fi
	done
    else
	_Dbg_msg "No display expressions have been set."
    fi
    return 0
}
