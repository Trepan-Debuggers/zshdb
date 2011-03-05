# -*- shell-script -*-
# validate.sh - some input validation routines
#
#   Copyright (C) 2010, 2011
#   Rocky Bernstein <rocky@gnu.org>
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

# _Dbg_is_function returns 0 if $1 is a defined function or nonzero otherwise. 
# if $2 is nonzero, system functions, i.e. those whose name starts with
# an underscore (_), are included in the search.

# _Dbg_is_alias returns 0 if $1 is an alias or nonzero otherwise. 
_Dbg_is_alias() {
    # setopt ksharrays  # Done in _Dbg_debug_trap_handler
    (( 0 == $# )) && return 1
    typeset needed_alias=$1
    typeset al
    al=$(alias $needed_alias 2>&1)
    return $?
}

_Dbg_is_function() {
    # setopt ksharrays  # Done in _Dbg_debug_trap_handler
    (( 0 == $# )) && return 1
    typeset needed_fn=$1
    typeset -i include_system=${2:-0}
    [[ ${needed_fn[0,0]} == '_' ]] && ((!include_system)) && {
	return 1
    }
    typeset fn
    fn=$(declare -f $needed_fn 2>&1)
    [[ -n "$fn" ]]
    return $?
}

# _Dbg_is_int returns 0 if $1 is an integer or nonzero otherwise. 
_Dbg_is_int() {
    (( 1 == $# )) || return 1
    if [[ $1 == [0-9]* ]] ; then
	return 0
    else
	return 1
    fi
}

# _Dbg_is_signed_int returns 0 if $1 is an integer or nonzero otherwise. 
_Dbg_is_signed_int() {
    (( 1 == $# )) || return 1
    if [[ $1 == [0-9]* ]] || [[ $1 == [+-][0-9]* ]] ; then
	return 0
    else
	return 1
    fi
}
