# -*- shell-script -*-
# up.sh - gdb-like "up" debugger command
#
#   Copyright (C) 2010 Rocky Bernstein
#   rocky@gnu.org
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
_Dbg_help_add up \
'up [COUNT] 

Move the current frame up in the stack trace (to an older frame). 0 is
the most recent frame. 

If COUNT is omitted, use 1. COUNT can be any arithmetic expression.

See also "down" and "frame".'

function _Dbg_do_up {
  _Dbg_not_running && return 1
  typeset -il count=${1:-1}
  _Dbg_frame_adjust $count +1
  _Dbg_last_cmd='up'
  return 0
}

_Dbg_alias_add 'u' up
