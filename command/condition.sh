# -*- shell-script -*-
# condition.sh - gdb-like "condition" debugger command
#
#   Copyright (C) 2009 Rocky Bernstein  rocky@gnu.org
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

_Dbg_help_add condition \
"condition N COND	-- Break only if COND is true in breakpoint number N.

N is an integer and COND is an expression to be evaluated whenever 
breakpoint N is reached."

# Set a condition for a given breakpoint $1 is a breakpoint number
# $2 is a condition. If not given, set "unconditional" or 1.
# returns 0 if success or 1 if fail.
function _Dbg_do_condition {
  # set -x
  typeset -r n=$1
  typeset condition="$@"
  # set -xv

  if [[ -z $n ]]; then
    _Dbg_msg 'Argument required (breakpoint number).'
    return 1
  fi

  if [[ $n != [0-9]* ]]; then
    _Dbg_msg "Bad breakpoint number: $n"
    return 1
  fi

  if [[ -z ${_Dbg_brkpt_file[$n]} ]] ; then
    _Dbg_msg "Breakpoint entry $n is not set. Condition not changed."
    return 1
  fi
  
  if [[ -z $condition ]] ; then
    condition=1
    _Dbg_msg "Breakpoint $n now unconditional."
  fi
  _Dbg_brkpt_cond[$n]="$condition"
  return 0
}
