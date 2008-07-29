# -*- shell-script -*-
# backtrace.cmd - gdb-like frame debugger command
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

# Print a stack backtrace.  
# $1 is the maximum number of entries to include.

# This code assumes the version of zsh where functrace has file names
# and absolute line positions, not function names and offset.

_Dbg_do_backtrace() {

  if (( ! _Dbg_running )) ; then
      _Dbg_msg "No stack."
      return
  fi

  local prefix='##'
  local -i n=${#_Dbg_frame_stack}
  local -i count=${1:-$n}
  local -i i=1

  # Loop which dumps out stack trace.
  for (( i=1 ; (( i <= n && count > 0 )) ; i++ )) ; do 
    prefix='##'
    (( i == _Dbg_stack_pos)) && prefix='->'

    prefix+="$i "
    if ((i!=1)) ; then 
	prefix+="${_Dbg_func_stack[i-1]} called from"
    else
	prefix+='in'
    fi

    local file_line="${_Dbg_frame_stack[i]}"
    _Dbg_split "$file_line" ':'
    typeset filename=${split_result[1]}
    typeset -i line=${split_result[2]}
    (( _Dbg_basename_only )) && filename=${filename##*/}
    _Dbg_msg "$prefix file \`$filename' at line ${line}"
    ((count++))
  done
  return 0
}
