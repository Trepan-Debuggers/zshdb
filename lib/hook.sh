# -*- shell-script -*-
# hook.sh - Debugger trap hook
#
#   Copyright (C) 2008, 2009, 2010, 2011, 2018
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

typeset -i _Dbg_set_debug=0       # 1 if we are debug the debugger
typeset    _Dbg_stop_reason=''    # The reason we are in the debugger.
typeset -i _Dbg_rc=0

typeset -i _Dbg_QUIT_LEVELS=0     # Number of nested shells we have to exit

# Return code that debugged program reports
typeset -i _Dbg_program_exit_code=0

# This is the main hook routine that gets called before every statement.
# It's the function called via trap DEBUG.
function _Dbg_trap_handler {

    # Save old set options before destroying them
    _Dbg_old_set_opts=$-

    # Turn off line and variable trace listing.
    ((!_Dbg_set_debug)) && set +x
    set +v +u +e

    _Dbg_set_debugger_entry 'create_unsetopt'
    # If some options are set (like localtraps?) then
    # some of the above doesn't work. So repeat some of it.
    setopt ksharrays shwordsplit norcs
    unsetopt $_Dbg_debugger_unset_opts

    trap '_Dbg_hook_error_handler' ERR

    typeset -i _Dbg_debugged_exit_code=$1
    shift

    # Populate _Dbg_arg with $1, $2, etc.
    typeset -a _Dbg_arg
    _Dbg_arg=($@)   # Does this require shword split off?

    typeset -i _Dbg_skipping_fn
    ((_Dbg_skipping_fn =
	    (_Dbg_return_level >= 0 &&
	     ${#funcfiletrace[@]} > _Dbg_return_level) ))

    if [[ -r $_Dbg_journal  ]] ; then
	_Dbg_source_journal
    fi

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
	    ((_Dbg_skip_ignore--))
	    _Dbg_write_journal "_Dbg_skip_ignore=$_Dbg_skip_ignore"
	    _Dbg_set_to_return_from_debugger 2
	    return 2 # 2 indicates skip statement.
	fi
    fi

    # FIXME: look for watchpoints

    typeset full_filename
    typeset file_line
    file_line=${funcfiletrace[0]}
    typeset -a split_result; _Dbg_split "$file_line" ':'
    filename=${split_result[0]}
    lineno=${split_result[1]}
    full_filename=$(_Dbg_is_file $filename)
    if [[ -r $full_filename ]] ; then
	_Dbg_file2canonic[$filename]="$full_filename"
    fi

    # Run applicable action statement
    if ((_Dbg_action_count > 0)) ; then
	_Dbg_hook_action_hit "$full_filename"
    fi

    # Determine if we stop or not.

    # Check breakpoints.
    if ((_Dbg_brkpt_count > 0)) ; then
	if _Dbg_hook_breakpoint_hit "$full_filename"; then
	    if ((_Dbg_step_force)) ; then
		typeset _Dbg_frame_previous_file="$_Dbg_frame_last_filename"
		typeset -i _Dbg_frame_previous_lineno="$_Dbg_frame_last_lineno"
	    fi
	    _Dbg_frame_save_frames 1
	    ((_Dbg_brkpt_counts[_Dbg_brkpt_num]++))
	    _Dbg_msg "Breakpoint $_Dbg_brkpt_num hit."
	    if (( _Dbg_brkpt_onetime[_Dbg_brkpt_num] == 1 )) ; then
		_Dbg_stop_reason='at a breakpoint that has since been deleted'
		_Dbg_delete_brkpt_entry $_Dbg_brkpt_num
	    else
		_Dbg_stop_reason="at breakpoint $_Dbg_brkpt_num"
	    fi
	    _Dbg_hook_enter_debugger "$_Dbg_stop_reason"
	    return $?
	fi
    fi

    # Check if step mode and number of steps to ignore.
    if ((_Dbg_step_ignore == 0 && ! _Dbg_skipping_fn )); then

	if ((_Dbg_step_force)) ; then
	    typeset _Dbg_frame_previous_file="$_Dbg_frame_last_filename"
	    typeset -i _Dbg_frame_previous_lineno="$_Dbg_frame_last_lineno"
	    _Dbg_frame_save_frames 1
	    if ((_Dbg_frame_previous_lineno == _Dbg_frame_last_lineno)) && \
		[ "$_Dbg_frame_previous_file" = "$_Dbg_frame_last_filename" ] ; then
		_Dbg_set_to_return_from_debugger
		return 0
	    fi
	else
	    _Dbg_frame_save_frames 1
	fi

	_Dbg_hook_enter_debugger 'after being stepped'
	return $?

    fi
    if ((_Dbg_set_linetrace)) ; then
	if ((_Dbg_linetrace_delay)) ; then
	    sleep $_Dbg_linetrace_delay
	fi

	_Dbg_frame_save_frames 1
	_Dbg_print_location_and_command
    fi
    _Dbg_set_to_return_from_debugger
    return 0
}

_Dbg_hook_action_hit() {
    typeset full_filename="$1"
    typeset lineno=$_Dbg_frame_last_lineno # NOT USED. FIXME
    # FIXME remove below
    typeset file_line
    file_line=${funcfiletrace[1]}
    typeset -a split_result; _Dbg_split "$file_line" ':'
    filename=${split_result[0]}
    typeset lineno=$_Dbg_frame_last_lineno
    lineno=${split_result[1]}

    # FIXME: combine with _Dbg_unset_action
    typeset -a linenos
    [[ -z "$full_filename" ]] && return 1
    eval "linenos=(${_Dbg_action_file2linenos[$full_filename]})"
    typeset -a action_nos
    eval "action_nos=(${_Dbg_action_file2action[$full_filename]})"

    typeset -i _Dbg_i
    # Check action within full_filename
    for ((_Dbg_i=0; _Dbg_i < ${#linenos[@]}; _Dbg_i++)); do
	if (( linenos[_Dbg_i] == lineno )) ; then
	    (( _Dbg_action_num = action_nos[_Dbg_i] ))
	    stmt="${_Dbg_action_stmt[$_Dbg_action_num]}"
  	    . ${_Dbg_libdir}/lib/set-d-vars.sh
  	    eval "$stmt"
	    # We've reset some variables like IFS and PS4 to make eval look
	    # like they were before debugger entry - so reset them now.
	    _Dbg_set_debugger_internal
	    return 0
	fi
    done
    return 1
}

# Return 0 if we are at a breakpoint position or 1 if not.
# Sets _Dbg_brkpt_num to the breakpoint number found.
_Dbg_hook_breakpoint_hit() {
    typeset full_filename="$1"
    typeset lineno=$_Dbg_frame_last_lineno # NOT USED. FIXME
    # FIXME remove below
    typeset file_line
    file_line=${funcfiletrace[1]}
    typeset -a split_result; _Dbg_split "$file_line" ':'
    filename=${split_result[0]}
    lineno=${split_result[1]}

    # FIXME: combine with _Dbg_unset_brkpt
    typeset -a linenos
    eval "linenos=(${_Dbg_brkpt_file2linenos[$full_filename]})"
    typeset -a brkpt_nos
    eval "brkpt_nos=(${_Dbg_brkpt_file2brkpt[$full_filename]})"
    typeset -i i
    # Check breakpoints within full_filename
    for ((i=0; i < ${#linenos[@]}; i++)); do
	if (( linenos[i] == lineno )) ; then
	    # Got a match, but is the breakpoint enabled and condition met?
	    (( _Dbg_brkpt_num = brkpt_nos[i] ))
            if ((_Dbg_brkpt_enable[_Dbg_brkpt_num] )); then
		if ( eval "((${_Dbg_brkpt_cond[_Dbg_brkpt_num]}))" || eval "${_Dbg_brkpt_cond[_Dbg_brkpt_num]}" ) 2>/dev/null; then
                    return 0
		else
                    _Dbg_msg "Breakpoint: evaluation of '${_Dbg_brkpt_cond[_Dbg_brkpt_num]}' returned false."
		fi
	    fi
	fi
    done
    return 1
}

# Go into the command loop
_Dbg_hook_enter_debugger() {
    _Dbg_stop_reason="$1"
    _Dbg_print_location_and_command
    _Dbg_process_commands
    _Dbg_set_to_return_from_debugger $?
    return $_Dbg_rc # _Dbg_rc set to $? by above
}

# Cleanup routine: erase temp files before exiting.
_Dbg_cleanup() {
    ((_Dbg_history_save != 0)) && _Dbg_history_write
    [[ -f $_Dbg_evalfile ]] && rm -f $_Dbg_evalfile 2>/dev/null
    set +u
    if [[ -n "$_Dbg_EXECUTION_STRING" ]] && [[ -r "$_Dbg_script_file" ]] ; then
	rm "$_Dbg_script_file"
    fi
    _Dbg_erase_journals || true  # ignore return code for now
    _Dbg_restore_user_vars

}

# Follows bashdb which reports:
# Somehow we can't put this in _Dbg_cleanup and have it work.
# I am not sure why.
_Dbg_cleanup2() {
    [[ -f "$_Dbg_evalfile" ]] && rm -f "$_Dbg_evalfile" 2>/dev/null
    _Dbg_erase_journals
    trap - EXIT
    ls -l ${_Dbg_journal}
}

_Dbg_hook_error_handler() {
    print ERROR AT: ${funcfiletrace[@]}
    # Set to make sure we stop after we return
    _Dbg_write_journal_eval "_Dbg_step_ignore=1"
}
