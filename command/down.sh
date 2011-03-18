# -*- shell-script -*-
# gdb-like "down" debugger command
#
#   Copyright (C) 2010, 2011 Rocky Bernstein
#   <rocky@gnu.org>
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

# Move default values down $1 or one in the stack.

# Move default values up $1 or one in the stack.
_Dbg_help_add down \
'down [COUNT]

Move the current frame down in the stack trace (to an newer frame). 0 is
the most recent frame.

If COUNT is omitted, use 1. COUNT can be any arithmetic expression.

See also "up" and "frame".'

function _Dbg_do_down {
    _Dbg_not_running && return 1
    typeset count=${1:-1}
    _Dbg_is_signed_int $count
    if (( 0 == $? )) ; then
        _Dbg_frame_adjust $count -1
        typeset -i rc=$?
    else
        _Dbg_errmsg "Expecting an integer; got $count"
        typeset -i rc=2
    fi
    return 0
}

