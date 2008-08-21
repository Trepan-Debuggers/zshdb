# -*- shell-script -*-
# gdb.sh - routines that seem tailored more to the gdb-style of doing things.
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

# Print location in gdb-style format: file:line
# So happens this is how it's stored in global _Dbg_frame_stack which
# is where we get the information from
function _Dbg_print_location {
    if (($# > 1)); then 
      _Dbg_errmsg "got $# parameters, but need 0 or 1."
      return 2
    fi
    typeset -i pos=${1:-${_Dbg_stack_pos}}
    typeset file_line="${_Dbg_frame_stack[$pos]}"

    _Dbg_split "$file_line" ':'

    typeset filename=${split_result[0]}
    typeset -i line=${split_result[1]}
    if ((_Dbg_basename_only)); then
	filename=${filename##*/}
	file_line="${filename}:${line}"
    fi
    ((pos1=1))
    if [[ $filename == $_Dbg_func_stack[pos1] ]] ; then
	_Dbg_msg "($file_line): -- nope"
    else
	_Dbg_msg "($file_line):"
    fi
}

# Print position $1 of stack frame (from global _Dbg_frame_stack)
# Prefix the entry with $2 if that's set.
function _Dbg_print_frame {
    if (($# > 2)); then 
      _Dbg_errmsg "got $# parameters, but need 0 or 1."
      return -1
    fi

    typeset -i pos=${1:-$_Dbg_stack_pos}
    typeset file_line="${_Dbg_frame_stack[$pos]}"
    typeset prefix=${2:-''}

    _Dbg_split "$file_line" ':'
    typeset filename=${split_result[0]}
    typeset -i line=${split_result[1]}
    (( _Dbg_basename_only )) && filename=${filename##*/}
    _Dbg_msg "$prefix file \`$filename' at line $line"

}

