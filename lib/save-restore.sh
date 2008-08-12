# -*- shell-script -*-
#  Save and restore user settings
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

# set dollar variables ($1, $2, ... $?) 
# to their values in the debugged environment before we entered the debugger.

typeset _Dbg_restore_unsetopts=' '
_Dbg_set_debugger_entry() {

  _Dbg_old_IFS="$IFS"
  _Dbg_old_PS4="$PS4"
  typeset unset_opts; _Dbg_create_unsetopt ksharrays
  _Dbg_restore_unsetopt=$unset_opts
  _Dbg_set_debugger_internal
}

# Return 0 if $1 is not a zsh option set
_Dbg_is_unsetopt() {
    (( $# != 1 )) || [[ -z $1 ]] && return 2
    typeset opt=$1
    typeset old_IFS
    old_IFS="$IFS"
    IFS=''
    typeset opts=$(setopt | tr '
' ' ')
    IFS="$old_IFS"
    [[ ${opts[@]} == *$opt* ]] && return 1
    return 0
}

# Set string unset_opts to be those zsh options in $* that are not set.
function _Dbg_create_unsetopt {
    unset_opts=''
    for opt ; do
	_Dbg_is_unsetopt $opt && unset_opts="$unset_opts $opt"
    done
}


# Does things to after on entry of after an eval to set some debugger
# internal settings  
_Dbg_set_debugger_internal() {
  IFS="$_Dbg_space_IFS"
  PS4='%N:%i: %? zshdb
'
  setopt ksharrays
}

_Dbg_restore_user_vars() {
  IFS="$_Dbg_space_IFS"
  set -$_Dbg_old_set_opts
  IFS="$_Dbg_old_IFS";
  PS4="$_Dbg_old_PS4"
  [[ -n $_Dbg_restore_unsetopt ]] && eval "unsetopt $_Dbg_restore_unsetopt"
}

_Dbg_set_to_return_from_debugger() {
    _Dbg_rc=$?

#   _Dbg_currentbp=0
#   _Dbg_stop_reason=''
#   if (( $1 != 0 )) ; then
#     _Dbg_last_bash_command="$_Dbg_bash_command"
#     _Dbg_last_curline="$_curline"
#     _Dbg_last_source_file="$_cur_source_file"
#   else
#     _Dbg_last_curline==${BASH_LINENO[1]}
#     _Dbg_last_source_file=${BASH_SOURCE[2]:-$_Dbg_bogus_file}
#     _Dbg_last_bash_command="**unsaved _bashdb command**"
#   fi

#   if (( _Dbg_restore_debug_trap )) ; then
#     trap '_Dbg_debug_trap_handler 0 "$BASH_COMMAND" "$@"' DEBUG
#   else
#     trap - DEBUG
#   fi  

  _Dbg_restore_user_vars
}
