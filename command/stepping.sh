# -*- shell-script -*-
# stepping.cmd - gdb-like "step" and "skip" debugger commands
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

# Number of statements to skip before entering the debugger if greater than 0
typeset -i _Dbg_skip_ignore=0

add_help skip \
'skip [ nnn]	skip once or nnn times.'

# Skip command
# $1 is an optional additional count.
_Dbg_do_skip() {

  _Dbg_not_running && return 1

  local count=${1:-1}

  if [[ $count == [0-9]* ]] ; then
    _Dbg_skip_count=${count:-1}
  else
    _Dbg_msg "Argument ($count) should be a number or nothing."
    _Dbg_skip_count=0
    return 0
  fi
  _Dbg_write_journal "_Dbg_skip_count=$_Dbg_skip_count"
  return 2
}

add_help step \
'step [ nnn]	step (into functions) once or nnn times.'

# Step command
# $1 is an optional additional count.
_Dbg_do_step() {

  _Dbg_not_running && return 1

  local count=${1:-1}

  if [[ $count == [0-9]* ]] ; then
    _Dbg_step_ignore=${count:-1}
  else
    _Dbg_msg "Argument ($count) should be a number or nothing."
    _Dbg_step_ignore=1
    return 0
  fi
  _Dbg_write_journal "_Dbg_step_ignore=$_Dbg_step_ignore"
  return 1
}
