# -*- shell-script -*-
# frame.sh - Call Stack routines
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

#================ VARIABLE INITIALIZATIONS ====================#

# Where are we in stack? This can be changed by "up", "down" or "frame"
# commands.

typeset -i _Dbg_stack_pos=0

# Array of file:line string from functrace.
typeset -a _Dbg_frame_stack
typeset -a _Dbg_func_stack

# Save the last-entered frame for to determine stopping when
# "set force" or step+ is in effect.
typeset _Dbg_frame_last_filename=''
typeset -i _Dbg_frame_last_lineno=0

#======================== FUNCTIONS  ============================#

_Dbg_frame_adjust() {
  (($# != 2)) && return -1

  local -i count="$1"
  local -i signum="$2"

  local -i retval
  _Dbg_frame_int_setup $count || return 2

  local -i pos
  if (( signum==0 )) ; then
    if (( count < 0 )) ; then
      ((pos=${#_Dbg_frame_stack[@]}+count))
    else
      ((pos=count))
    fi
  else
    ((pos=_Dbg_stack_pos+(count*signum)))
  fi

  if (( $pos < 0 )) ; then 
    _Dbg_errmsg 'Would be beyond bottom-most (most recent) entry.'
    return 1
  elif (( pos >= ${#_Dbg_frame_stack[@]} )) ; then 
    _Dbg_errmsg 'Would be beyond top-most (least recent) entry.'
    return 1
  fi

  ((_Dbg_stack_pos = pos))

}

_Dbg_frame_file() {
    (($# > 1)) && return 2
    # FIXME check to see that $1 doesn't run off the end.
    typeset -i pos=${1:-$_Dbg_stack_pos}
    typeset file_line="${_Dbg_frame_stack[$pos]}"
    _Dbg_split "$file_line" ':'
    _Dbg_frame_filename=${split_result[0]}
    (( _Dbg_basename_only )) && _Dbg_frame_filename=${_Dbg_frame_filename##*/}
    return 0
}

# Tests for a signed integer parameter and set global retval
# if everything is okay. Retval is set to 1 on error
_Dbg_frame_int_setup() {

  _Dbg_not_running && return 1
  setopt EXTENDED_GLOB
  if [[ $1 != '' && $1 != ([-+]|)([0-9])## ]] ; then 
      _Dbg_errmsg "Bad integer parameter: $1"
      # Reset EXTENDED_GLOB
      return 1
  fi
  # Reset EXTENDED_GLOB
  return 0
}

_Dbg_frame_lineno() {
    (($# > 1)) && return -1
    # FIXME check to see that $1 doesn't run off the end.
    typeset -i pos=${1:-$_Dbg_stack_pos}
    typeset file_line="${_Dbg_frame_stack[$pos]}"
    _Dbg_split "$file_line" ':'
    typeset -i line=${split_result[1]}
    return $line
}

# Save stack frames in array _Dbg_frame_stack ignoring the 
# first (most recent) $1 of these. We assume "setopt ksharrarrys" 
# (origin 0) has beeen set previously.
_Dbg_frame_save_frames() {
    typeset ignore=${1:-0}
    typeset -i i
    typeset -i j=$ignore
    typeset -i n=${#funcfiletrace[@]}
    _Dbg_frame_stack=()
    _Dbg_func_stack=()
    for ((i=0; j < n; i++, j++)) ; do
	_Dbg_frame_stack[i]=${funcfiletrace[j]}
	_Dbg_func_stack[i]=${funcstack[j]}
    done

    # Remove our function name. Shouldn't need to do,
    # but there have been bugs.
    (( ${#_Dbg_func_stack} > 1 )) && shift _Dbg_func_stack 

    # Set stack position to the most recent entry.
    _Dbg_stack_pos=0
    typeset file_line="${_Dbg_frame_stack[0]}"
    _Dbg_split "$file_line" ':'
    _Dbg_frame_last_file=${split_result[0]}
    _Dbg_frame_last_lineno=${split_result[1]}

}
