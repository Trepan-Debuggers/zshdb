# -*- shell-script -*-
# frame.sh - gdb-like "up", "down" and "frame" debugger commands
#
#   Copyright (C) 2008 Rocky Bernstein rocky@gnu.org
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

# Move default values down $1 or one in the stack. 

_Dbg_help_add down \
'down [COUNT]	-- Set the call stack position down by COUNT.

If COUNT is omitted use 1.'

_Dbg_do_down() {
  _Dbg_not_running && return 1
  typeset -i count=${1:-1}
  _Dbg_frame_adjust $count -1
  _Dbg_print_location
}

_Dbg_alias_add 'd' down

_Dbg_help_add frame \
'frame FRAME-NUM	-- Move the current frame to the FRAME-NUM.'

_Dbg_do_frame() {
  _Dbg_not_running && return 1
  typeset -i pos=${1:-0}
  _Dbg_frame_adjust $pos 0
  _Dbg_print_location
}

# Move default values up $1 or one in the stack. 
_Dbg_help_add up \
'up [COUNT]	-- Set the call stack position up by  COUNT. 

If count is omitted use 1.'

_Dbg_do_up() {
  _Dbg_not_running && return 1
  typeset -i count=${1:-1}
  _Dbg_frame_adjust $count +1
  _Dbg_print_location
}

_Dbg_alias_add 'u' 'up'
