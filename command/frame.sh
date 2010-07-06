# -*- shell-script -*-
# frame.sh - gdb-like "frame" debugger commands
#
#   Copyright (C) 2008, 2010 Rocky Bernstein rocky@gnu.org
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

_Dbg_help_add frame \
'frame [FRAME-NUMBER].

Change the current frame to frame FRAME-NUMBER if specified, or the
most-recent frame, 0, if no frame number specified.

A negative number indicates the position from the other or 
least-recently-entered end.  So "frame -1" moves to the oldest frame.
'

_Dbg_do_frame() {
  _Dbg_not_running && return 1
  typeset -li pos=${1:-0}
  _Dbg_frame_adjust $pos 0
}
