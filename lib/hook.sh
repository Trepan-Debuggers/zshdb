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
    setopt localtraps norcs ksharrays
    # FIXME figure out what below uses shwordsplit.
    trap 'print ERROR AT: ${funcfiletrace[@]}' ERR

    typeset -i _Dbg_debugged_exit_code=$1
    shift

    # Place to save values of $1, $2, etc.
    typeset -a _Dbg_arg
    _Dbg_arg=($@)   # Does this require shword split off? 

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
	    _Dbg_set_to_return_from_debugger 1
	    return 2 # 2 indicates skip statement.
	fi
    fi
    
    typeset -i set_entry_called=0
    # Determine if we stop or not. 

    # Check breakpoints.
    if ((_Dbg_brkpt_count > 0)) ; then 
	_Dbg_set_debugger_entry; set_entry_called=1
	typeset -i _Dbg_brkpt_num
	if _Dbg_hook_breakpoint_hit ; then 
	    if ((_Dbg_step_force)) ; then
		typeset _Dbg_frame_previous_file="$_Dbg_frame_last_file"
		typeset -i _Dbg_frame_previous_lineno="$_Dbg_frame_last_lineno"
	    fi
	    _Dbg_frame_save_frames 1
	    ((_Dbg_brkpt_counts[_Dbg_brkpt_num]++))
	    _Dbg_msg "Breakpoint $_Dbg_brkpt_num hit."
	    if (( ${_Dbg_brkpt_onetime[_Dbg_brkpt_num]} == 1 )) ; then
		_Dbg_stop_reason='at a breakpoint that has since been deleted'
		_Dbg_delete_brkpt_entry $_Dbg_brkpt_num
	    else
		_Dbg_stop_reason='breakpoint reached'
	    fi
	    _Dbg_hook_enter_debugger $_Dbg_stop_reason
	    return $?
	fi
    fi

    # Check if step mode and number of steps to ignore.
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
		return 0
	    fi
	else
	    _Dbg_frame_save_frames 1
	fi

	_Dbg_hook_enter_debugger 'after being stepped'
	return $?

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
	return 0
    fi
}

# Return 0 if we are at a breakpoint position or 1 if not.
# Sets _Dbg_brkpt_num to the breakpoint number found.
_Dbg_hook_breakpoint_hit() {
    typeset full_filenaname
    typeset file_line
    file_line=${funcfiletrace[1]}
    _Dbg_split "$file_line" ':'
    full_filename=${split_result[0]}
    lineno=${split_result[1]}
    full_filename=$(_Dbg_is_file $full_filename)
    typeset -a linenos
    linenos=${_Dbg_brkpt_file2linenos[$full_filename]}
    typeset -i try_lineno
    typeset -i i=-1
    # Check breakpoints within full_filename
    for try_lineno in $linenos ; do 
	((i++))
	if (( try_lineno == lineno )) ; then
	    # Got a match, but is the breakpoint enabled? 
	    typeset -a brkpt_nos; brkpt_nos=(${_Dbg_brkpt_file2brkpt[$full_filename]})
	    (( _Dbg_brkpt_num = brkpt_nos[i] ))
	    if ((_Dbg_brkpt_enable[_Dbg_brkpt_num] )) ; then
		return 0
	    fi
	fi
    done
    return 1
}

# Go into the command loop
_Dbg_hook_enter_debugger() {
    _Dbg_stop_reason="$1"
    typeset -i _Dbg_rc=0
    _Dbg_print_location_and_command
    _Dbg_process_commands
    _Dbg_set_to_return_from_debugger 1
    return $_Dbg_rc
}

# Cleanup routine: erase temp files before exiting.
_Dbg_cleanup() {
  rm $_Dbg_evalfile 2>/dev/null
  _Dbg_erase_journals
  _Dbg_restore_user_vars
}
