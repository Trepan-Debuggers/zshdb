# -*- shell-script -*-
# This program needs to be SOURCE'd and is not called as an executable
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
#

# Enter the debugger at the calling stack frame.  This is useful to
# hard-code a breakpoint at a given point in a program, even if the code
# is not otherwise being debugged.
# Leaving this the debugger terminates the program.

# Any parameters after the first one are exec'd. In this way you can
# force specific options to get set.
_Dbg_debugger() {
  typeset _Dbg_trace_old_set_opts=$-
  set +u
  if (( $# > 0 )) ; then
      step_ignore=$1
      shift
  else
      typeset step_ignore=${_Dbg_step_ignore:-''}
  fi

  while (( $# > 0 )) ; do
    eval $1
    shift
  done

  if [[ -z $_Dbg_set_trace_init ]] ; then
      _Dbg_set_trace_init=1
      _Dbg_step_ignore=${step_ignore:-0}
      _Dbg_write_journal "_Dbg_step_ignore=0"
  else
      _Dbg_step_ignore=${1:-1}
  fi
  set -${_Dbg_trace_old_set_opts}
  unset _Dbg_trace_old_set_opts
  trap '_Dbg_trap_handler $? "$@"; ((2==$?)) && setopt errexit' DEBUG
}
