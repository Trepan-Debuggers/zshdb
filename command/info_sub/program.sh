# -*- shell-script -*-
# gdb-like "info program" debugger command
#
#   Copyright (C) 2010, 2014, 2016 Rocky Bernstein rocky@gnu.org
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

_Dbg_help_add_sub info program '
**info program**

Information about debugged program stopping point.

See also:
---------

\"info line\".' 1

_Dbg_do_info_program() {
    if (( _Dbg_running )) ; then
        _Dbg_msg 'Program stopped.'
        if [[ -n $_Dbg_stop_reason ]] ; then
            _Dbg_msg "It stopped ${_Dbg_stop_reason}."
        fi
        _Dbg_msg "Next statement to be run is:"
        _Dbg_print_command
    else
        _Dbg_errmsg 'The program being debugged is not being run.'
        return 1
    fi
    return 0
}
