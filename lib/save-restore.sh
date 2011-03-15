# -*- shell-script -*-
#  Save and restore user settings
#
#   Copyright (C) 2008, 2010, 2011 Rocky Bernstein <rocky@gnu.org>
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

# Options which are set inside the debugger
[[ -z $_Dbg_debugger_set_opts ]] && \
  typeset -r _Dbg_debugger_set_opts=\
'extendedhistory extendedglob shwordsplit ksharrays histignoredups zle rematchpcre bashrematch'

# Options which are unset inside the debugger
[[ -z $_Dbg_debugger_unset_opts ]] && \
  typeset -r _Dbg_debugger_unset_opts='localtraps'

# Options to save/restore between entering/leaving the debugger
[[ -z $_Dbg_check_opts ]] && \
  typeset -r _Dbg_check_opts=\
"$_Dbg_debugger_set_opts $_Dbg_debugger_unset_opts"

# Do things for debugger entry. Set some global debugger variables
# Remove trapping ourselves. 
# We assume that we are nested two calls deep from the point of debug
# or signal fault. If this isn't the constant 2, then consider adding
# a parameter to this routine.
_Dbg_set_debugger_entry() {

    _Dbg_rc=0
    _Dbg_return_rc=0
    _Dbg_old_IFS="$IFS"
    _Dbg_old_PS4="$PS4"
    if (( $# > 0 )) ; then
	_Dbg_create_unsetopt "$_Dbg_check_opts"
    fi
    _Dbg_set_debugger_internal
    _Dbg_source_journal
    if (( _Dbg_QUIT_LEVELS > 0 )) ; then
	_Dbg_do_quit $_Dbg_debugged_exit_code
    fi
}

# Return 0 if $1 is not a zsh option set
_Dbg_is_unsetopt() {
    (( $# != 1 )) || [[ -z $1 ]] && return 2
    ! setopt | grep "$1" >/dev/null 2>&1
}

# Set string unset_opts to be those zsh options in $* that are not set.
function _Dbg_create_unsetopt {
    typeset unset_opts=''
    typeset set_opts=''
    eval "set -- $*"
    for opt ; do
	if _Dbg_is_unsetopt $opt ; then
	    unset_opts="$unset_opts $opt"
	else
	    set_opts="$set_opts $opt"
	fi
    done
    _Dbg_restore_unsetopt=$unset_opts
    _Dbg_restore_setopt=$set_opts
}


# Does things to after on entry of after an eval to set some debugger
# internal settings  
_Dbg_set_debugger_internal() {
  IFS="$_Dbg_space_IFS"
  PS4='(%x:%I): %? $_Dbg_debugger_name
'
  setopt ksharrays shwordsplit norcs bashrematch
  unsetopt $_Dbg_debugger_unset_opts
}

_Dbg_restore_user_vars() {
  IFS="$_Dbg_old_IFS"
  PS4="$_Dbg_old_PS4"
  [[ -n $_Dbg_restore_unsetopt ]] && eval "unsetopt $_Dbg_restore_unsetopt"
  [[ -n $_Dbg_restore_setopt ]] && eval "setopt $_Dbg_restore_setopt"
  set -$_Dbg_old_set_opts

}

_Dbg_set_to_return_from_debugger() {
    _Dbg_stop_reason=''
    _Dbg_listline=0
    _Dbg_rc=${1:-0}
    _Dbg_brkpt_num=0
    _Dbg_restore_user_vars
}

_Dbg_save_state() {
#   _Dbg_statefile=$(_Dbg_tempname statefile)
#   echo "" > $_Dbg_statefile
#   _Dbg_save_breakpoints
#   _Dbg_save_actions
#   _Dbg_save_watchpoints
#   _Dbg_save_display
#   _Dbg_save_Dbg_set
#   echo "unset DBG_RESTART_FILE" >> $_Dbg_statefile
#   echo "rm $_Dbg_statefile" >> $_Dbg_statefile
#   export DBG_RESTART_FILE="$_Dbg_statefile"
#   _Dbg_write_journal "export DBG_RESTART_FILE=\"$_Dbg_statefile\""
    :
}

_Dbg_restore_state() {
    typeset statefile=$1
   . $1
 }

# Things we do when coming back from a nested shell.
# "shell", and "debug" create nested shells.
_Dbg_restore_from_nested_shell() {
    rm -f $_Dbg_shell_temp_profile 2>&1 >/dev/null
    if [[ -r $_Dbg_restore_info ]] ; then
	. $_Dbg_restore_info
	rm $_Dbg_restore_info
    fi
}
