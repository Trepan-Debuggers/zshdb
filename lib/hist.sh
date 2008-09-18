# -*- shell-script -*-
# hist.sh - Bourne Again Shell Debugger history routines
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

typeset -i _Dbg_history_save=1
typeset _Dbg_history_file=${HOME:-.}/.${_Dbg_debugger_name}_hist

_Dbg_history_read() {
  if [[ -r $_Dbg_histfile ]] ; then 
    fc -R $_Dbg_histfile
  fi
}

_Dbg_history_write() {
  if [[ -w $_Dbg_histfile ]] ; then 
    fc -R $_Dbg_histfile
  fi
}

_Dbg_history_read

