# -*- shell-script -*-
# sig.sh - Debugger Signal handling routines
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

typeset _Dbg_stop_reason=''    # The reason we are in the debugger.

function _Dbg_debug_trap_handler {
    # setopt localtraps
    # trap 'echo EXIT encountered inside debugger' EXIT
    # trap 'echo ERR encountered inside debugger' ERR
    typeset -i _Dbg_debugged_exit_code=$?
    _Dbg_old_set_opts=$-

    # Place to save values of $1, $2, etc.
    typeset -a _Dbg_arg
    _Dbg_arg=($@)

    # Turn off line and variable trace listing if were not in our own debug
    # mode, and set our own PS4 for debugging inside the debugger
    (( !_Dbg_debug_debugger )) && set +x +v +u

    # if in step mode, decrement counter
    if ((_Dbg_step_ignore > 0)) ; then 
	((_Dbg_step_ignore--))
	_Dbg_write_journal "_Dbg_step_ignore=$_Dbg_step_ignore"
	# Can't return here because we may want to stop for another
	# reason.
    fi

    if ((_Dbg_skip_ignore > 0)) ; then
	_Dbg_set_debugger_entry
	((_Dbg_skip_ignore--))
	_Dbg_write_journal "_Dbg_skip_ignore=$_Dbg_skip_ignore"
	setopt errexit  # Set to skip statement

	_Dbg_set_to_return_from_debugger 1
	return $_Dbg_rc
    fi

    # Determine if we stop or not. 

    # Check if step mode and number steps to ignore.
    if ((_Dbg_step_ignore == 0)); then
	_Dbg_stop_reason='after being stepped'
	unsetopt errexit

	_Dbg_set_debugger_entry
	_Dbg_frame_save_frames 1
	_Dbg_print_location

	_Dbg_process_commands
	_Dbg_set_to_return_from_debugger 1
	(( $_Dbg_rc == 2 )) && setopt errexit  # Set to skip statement
	return $_Dbg_rc

    fi
    if ((_Dbg_linetrace)) ; then 
	if ((_Dbg_linetrace_delay)) ; then
	    sleep $_Dbg_linetrace_delay
	fi

	_Dbg_set_debugger_entry
	_Dbg_frame_save_frames 1
	_Dbg_print_location

	_Dbg_set_to_return_from_debugger 1
    fi
}

# Cleanup routine: erase temp files before exiting.
_Dbg_cleanup() {
  rm $_Dbg_evalfile 2>/dev/null
  _Dbg_erase_journals
  _Dbg_restore_user_vars
}

# Somehow we can't put this in _Dbg_cleanup and have it work.
# I am not sure why.
_Dbg_cleanup2() {
  _Dbg_erase_journals
  trap - EXIT
}
