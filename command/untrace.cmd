# -*- shell-script -*-
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

add_help untrace \
'untrace *function*	untrace previosly traced *function*'

# Undo wrapping fn
# $? is 0 if successful.
function _Dbg_do_untrace_fn {
    typeset -r fn=$1
    if [[ -z $fn ]] ; then
	_Dbg_errmsg "untrace_fn: missing or invalid function name."
	return 2
    fi
    _Dbg_is_function "$fn" || {
	_Dbg_errmsg "untrace_fn: function \"$fn\" is not a function."
	return 3
    }
    _Dbg_is_function "old_$fn" || {
	_Dbg_errmsg "untrace_fn: old function old_$fn not seen - nothing done."
	return 4
    }
    cmd=$(declare -f -- "old_$fn") || return 5
    cmd=${cmd#old_}
    ((_Dbg_debug_debugger)) && echo $cmd 
    eval "$cmd" || return 6
    return 0
}
