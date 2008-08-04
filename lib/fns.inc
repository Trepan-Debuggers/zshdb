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

# Add escapes to a string $1 so that when it is read back via "$1"
# it is the same as $1.
function _Dbg_esc_dq {
  builtin echo $1 | sed -e 's/[`$\"]/\\\0/g' 
}

# Set $? to $1 if supplied or the saved entry value of $?. 
function _Dbg_set_dol_q {
  [[ $# -eq 0 ]] && return $_Dbg_debugged_exit_code
  return $1
}

function _Dbg_errmsg {
    typeset -r prefix='**'
    _Dbg_msg "$prefix $@"
}

function _Dbg_errmsg_no_cr {
    typeset -r prefix='**'
    _Dbg_msg_no_cr "$prefix $@"
}

# _Dbg_is_function returns 0 if $1 is a defined function or nonzero otherwise. 
# if $2 is nonzero, system functions, i.e. those whose name starts with
# an underscore (_), are included in the search.
_Dbg_is_function() {
    typeset needed_fn=$1
    [[ -z $needed_fn ]] && return 1
    typeset -i include_system=${2:-0}
    [[ $needed_fn[1,1] == '_' ]] && ((!include_system)) && {
	return 1
    }
    typeset fn
    fn=$(declare -f $needed_fn 2>&1)
    [[ -n "$fn" ]]
    return $?
}

function _Dbg_msg {
    print -- "$@" 
}

function _Dbg_msg_nocr {
    echo -n $@
}

# Split string $1 into an array using delimitor $2 to split on
# The result is put in variable split_result
function _Dbg_split {
    local string="$1"
    local separator="$2"
    IFS="$separator" read -A split_result <<< $string
}

function _Dbg_set_debugger_entry {

  # Nuke DEBUG trap
  # trap '' DEBUG

  # _cur_fn=${FUNCNAME[2]}
  # let _curline=${BASH_LINENO[1]}
  # ((_curline < 1)) && let _curline=1

  _Dbg_old_IFS="$IFS"
  _Dbg_old_PS4="$PS4"
  # _cur_source_file=${BASH_SOURCE[2]:-$_Dbg_bogus_file}
  # _Dbg_stack_pos=$_Dbg_STACK_TOP
  # _Dbg_listline=_curline
  _Dbg_set_debugger_internal
  # _cur_source_file="`_Dbg_resolve_expand_filename $_cur_source_file`"
  # _cur_filevar="`_Dbg_file2var $_cur_source_file`"
}

# Does things to after on entry of after an eval to set some debugger
# internal settings  
function _Dbg_set_debugger_internal {
  IFS="$_Dbg_space_IFS";
  PS4='%N:%i: %? zsh+ '
}
