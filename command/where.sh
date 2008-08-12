# -*- shell-script -*-
# where.cmd - gdb-like "where" debugger command
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

# This code assumes the version of zsh where functrace has file names
# and absolute line positions, not function names and offset.

_Dbg_add_help where \
'where [n] 	Stack trace of calling functions or sourced files.'

# Print a stack backtrace.  
# $1 is the maximum number of entries to include.
_Dbg_do_backtrace() {

  _Dbg_not_running && return 1

  typeset prefix='##'
  typeset -i n=${#_Dbg_frame_stack}
  typeset -i count=${1:-$n}
  typeset -i i=1
  typeset -i im1

  # Loop which dumps out stack trace.
  for (( i=0 ; (( i < n && count > 0 )) ; i++ )) ; do 
    prefix='##'
    (( i == _Dbg_stack_pos)) && prefix='->'

    prefix+="$ "
    if ((i!=0)) ; then 
	prefix+="${_Dbg_func_stack[i-1]} called from"
    else
	prefix+='in'
    fi

    typeset file_line="${_Dbg_frame_stack[i]}"
    _Dbg_split "$file_line" ':'
    typeset filename=${split_result[0]}
    typeset -i line=${split_result[1]}
    (( _Dbg_basename_only )) && filename=${filename##*/}
    _Dbg_msg "$prefix file \`$filename' at line ${line}"
    ((count--))
  done
  return 0
}

_Dbg_add_alias bt where
_Dbg_add_alias T where
_Dbg_add_alias backtrace where
