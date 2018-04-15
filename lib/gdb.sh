# -*- shell-script -*-
# routines that seem tailored more to the gdb-style of doing things.
#   Copyright (C) 2008, 2011, 2015, 2018 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

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

    typeset split_result; _Dbg_split "$file_line" ':'
    typeset filename="${split_result[0]}"
    typeset -i line="${split_result[1]}"
    if [[ -n $filename ]] ; then
	_Dbg_readin "${filename}"
	if ((_Dbg_set_basename)); then
	    filename=${filename##*/}
	    file_line="${filename}:${line}"
	fi
	if [[ $filename == $_Dbg_func_stack[1] ]] ; then
	    _Dbg_msg "($file_line): -- nope"
	else
	    _Dbg_msg "($file_line):"
	fi
    fi
}

function _Dbg_print_command {
    typeset -i width; ((width=_Dbg_set_linewidth-6))
    if (( ${#ZSH_DEBUG_CMD} > width )) && [[ -n $_Dbg_set_highlight ]] ; then
	_Dbg_msg "${ZSH_DEBUG_CMD[0,$width]} ..."
    else
	if [[ -n $_Dbg_set_highlight ]] ; then
	    filter="${_Dbg_libdir}/lib/term-highlight.py --bg=${_Dbg_set_highlight}"
	    line=$(echo "$ZSH_DEBUG_CMD" | $filter 2>/dev/null)
	    if (( $? == 0 )) ; then
		_Dbg_msg "$line"
		return 0
	    fi
	fi
	_Dbg_msg $ZSH_DEBUG_CMD
    fi
}

function _Dbg_print_location_and_command {
    _Dbg_print_location $@
    _Dbg_print_command
}

# Print position $1 of stack frame (from global _Dbg_frame_stack)
# If $2 is set, show the source line code.
_Dbg_print_frame() {
    if (($# > 2)); then
      _Dbg_errmsg "got $# parameters, but need 0..2."
      return -1
    fi

    typeset -i pos; pos=${1:-$_Dbg_stack_pos}
    typeset -i show_source=${2:0}

    typeset prefix='##'
    (( pos == _Dbg_stack_pos)) && prefix='->'

    prefix+="$pos "
    if ((pos!=0)) ; then
	typeset fn_or_file; fn_or_file="${_Dbg_func_stack[$pos-1]}"
	(( _Dbg_set_basename )) && fn_or_file=${fn_or_file##*/}
        prefix+="$fn_or_file called from"
    else
        prefix+='in'
    fi

    typeset file_line
    file_line="${_Dbg_frame_stack[$pos]}"

    typeset -a split_result; _Dbg_split "$file_line" ':'
    typeset filename
    filename="${split_result[0]}"
    typeset -i line="${split_result[1]}"
    (( _Dbg_set_basename )) && filename=${filename##*/}
    _Dbg_msg "$prefix file \`$filename' at line $line"
    if (( show_source )) ; then
	_Dbg_list "$filename" $line 1
    fi

}
