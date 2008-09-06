# -*- shell-script -*-
# hook.sh - Debugger trap hook
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

typeset  -i _Dbg_debug_debugger=0  # 1 if we are debugging the debugger
typeset     _Dbg_stop_reason=''    # The reason we are in the debugger.

function _Dbg_debug_trap_handler {
    _Dbg_old_set_opts=$-
    # Turn off line and variable trace listing.
    set +x +v +u +e
    setopt localtraps
    trap 'print ERROR AT: ${funcfiletrace[@]}' ERR

    typeset -i _Dbg_debugged_exit_code=$1
    shift

    # Place to save values of $1, $2, etc.
    typeset -a _Dbg_arg
    _Dbg_arg=($@)

    typeset -i _Dbg_skipping_fn
    ((_Dbg_skipping_fn =
	    (_Dbg_return_level >= 0 && 
	     ${#funcfiletrace[@]} > _Dbg_return_level) ))

    # if in step mode, decrement counter
    if ((_Dbg_step_ignore > 0)) ; then 
	if ((! _Dbg_skipping_fn )) ; then
	    ((_Dbg_step_ignore--))
	    _Dbg_write_journal "_Dbg_step_ignore=$_Dbg_step_ignore"
	    # Can't return here because we may want to stop for another
	    # reason.
	fi
    fi

    if ((_Dbg_skip_ignore > 0)) ; then
	if ((! _Dbg_skipping_fn )) ; then
	    _Dbg_set_debugger_entry
	    ((_Dbg_skip_ignore--))
	    _Dbg_write_journal "_Dbg_skip_ignore=$_Dbg_skip_ignore"
	    setopt errexit  # Set to skip statement
	    
	    _Dbg_set_to_return_from_debugger 1
	    return $_Dbg_rc
	fi
    fi
    
    typeset -i set_entry_called=0
    # Determine if we stop or not. 

    # Check breakpoints.
    if ((_Dbg_brkpt_count > 0)) ; then 
	_Dbg_set_debugger_entry; set_entry_called=1
	typeset full_filenaname
	typeset file_line
	file_line=${funcfiletrace[-2]}
	_Dbg_split "$file_line" ':'
	full_filename=${split_result[0]}
	lineno=${split_result[1]}
	full_filename=$(_Dbg_is_file $full_filename)
	typeset -a linenos
	linenos=${_Dbg_brkpt_file2linenos[$full_filename]}
	if [[ $linenos =~ " $lineno "  ]] ; then
	    # TODO: check conditions and find actual entry.
	    if ((_Dbg_step_force)) ; then
		typeset _Dbg_frame_previous_file="$_Dbg_frame_last_file"
		typeset -i _Dbg_frame_previous_lineno="$_Dbg_frame_last_lineno"
		_Dbg_frame_save_frames 1
	    else
		_Dbg_frame_save_frames 1
	    fi
	    _Dbg_msg 'Breakpoint hit'
	    _Dbg_print_location_and_command
	    _Dbg_stop_reason='breakpoint reached'
	    _Dbg_process_commands
	    _Dbg_set_to_return_from_debugger 1
	    (( $_Dbg_rc == 2 )) && setopt errexit  # Set to skip statement
	    return $_Dbg_rc
	fi
    fi

    # Check if step mode and number steps to ignore.
    if ((_Dbg_step_ignore == 0 && ! _Dbg_skipping_fn )); then

	if ((set_entry_called == 0)) ; then
	    _Dbg_set_debugger_entry
	    set_entry_called=1
	fi
	if ((_Dbg_step_force)) ; then
	    typeset _Dbg_frame_previous_file="$_Dbg_frame_last_file"
	    typeset -i _Dbg_frame_previous_lineno="$_Dbg_frame_last_lineno"
	    _Dbg_frame_save_frames 1
	    if ((_Dbg_frame_previous_lineno == _Dbg_frame_last_lineno)) && \
		[ "$_Dbg_frame_previous_file" = "$_Dbg_frame_last_file" ] ; then
		_Dbg_set_to_return_from_debugger 1
		return $_Dbg_rc
	    fi
	else
	    _Dbg_frame_save_frames 1
	fi

	_Dbg_print_location_and_command

	_Dbg_stop_reason='after being stepped'
	_Dbg_process_commands
	_Dbg_set_to_return_from_debugger 1
	(( $_Dbg_rc == 2 )) && setopt errexit  # Set to skip statement
	return $_Dbg_rc

    fi
    if ((_Dbg_linetrace)) ; then 
	if ((_Dbg_linetrace_delay)) ; then
	    sleep $_Dbg_linetrace_delay
	fi

	if (($set_entry_called == 0)) ; then
	    _Dbg_set_debugger_entry
	    set_entry_called=1
	fi
	_Dbg_frame_save_frames 1
	_Dbg_print_location_and_command

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
