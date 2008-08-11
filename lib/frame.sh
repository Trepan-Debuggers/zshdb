# -*- shell-script -*-
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
# -*- shell-script -*-

#================ VARIABLE INITIALIZATIONS ====================#

# Where are we in stack? This can be changed by "up", "down" or "frame"
# commands.

typeset -i _Dbg_stack_pos=1
typeset -a _Dbg_frame_stack
typeset -a _Dbg_func_stack

#======================== FUNCTIONS  ============================#

_Dbg_adjust_frame() {
  typeset -i count=$1
  typeset -i signum=$2

  typeset -i retval
  _Dbg_stack_int_setup $count || return 

  typeset -i pos
  if (( signum==0 )) ; then
    if (( count < 0 )) ; then
      ((pos=${#_Dbg_func_stack}+count))
    else
      ((pos=count))
    fi
  else
    ((pos=_Dbg_stack_pos-1+(count*signum)))
  fi

  if (( $pos < 0 )) ; then 
    _Dbg_msg 'Would be beyond bottom-most (most recent) entry.'
    return 1
  elif (( $pos >= ${#_Dbg_frame_stack} )) ; then 
    _Dbg_msg 'Would be beyond top-most (least recent) entry.'
    return 1
  fi

  ((_Dbg_stack_pos = pos+1))
# #   typeset -i j=_Dbg_stack_pos+2
# #   _Dbg_listline=${BASH_LINENO[$j]}
# #   ((j++))
# #   _cur_source_file=${BASH_SOURCE[$j]}
# #   _Dbg_print_source_line $_Dbg_listline
#   return 0
}

# Print position $1 of stack frame (from global _Dbg_frame_stack)
# Prefix the entry with $2 if that's set.
function _Dbg_print_frame {
    typeset -i pos=${1:-$_Dbg_stack_pos}
    typeset file_line="${_Dbg_frame_stack[$pos]}"
    typeset prefix=${2:-''}

    _Dbg_split "$file_line" ':'
    typeset filename=${split_result[1]}
    typeset -i line=${split_result[2]}
    _Dbg_msg "$prefix$pos in file \`$filename' at line $line"

}

# Tests for a signed integer parameter and set global retval
# if everything is okay. Retval is set to 1 on error
_Dbg_stack_int_setup() {

  if (( ! _Dbg_running )) ; then
    _Dbg_errmsg "No stack."
    return 1
  else
    setopt EXTENDED_GLOB
    if [[ $1 != '' && $1 != ([-+]|)([0-9])## ]] ; then 
      _Dbg_msg "Bad integer parameter: $1"
      # Reset EXTENDED_GLOB
      return 1
    fi
    # Reset EXTENDED_GLOB
    return 0
  fi
}
