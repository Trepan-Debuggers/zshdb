# -*- shell-script -*-
#  Signal handling routines
#
#   Copyright (C) 2002, 2003, 2004, 2006, 2007, 2008, 2010,
#   2011 Rocky Bernstein <rocky@gnu.org>
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

# ==================== VARIABLES =======================================

# The "set" options in effect ($-) before debugger was invoked.
typeset _Dbg_old_setopts

# Place to save debugged program's exit handler, if any.
typeset _Dbg_old_EXIT_handler=''  

typeset -i _Dbg_QUIT_ON_QUIT=0

# Return code that debugged program reports
typeset -i _Dbg_program_exit_code=0

############################################################
## Signal arrays: These are indexed by the signal number. ##
############################################################

# Should we print that a signal was intercepted? 
# Each entry is "print" or "noprint" or null.
typeset -a _Dbg_sig_print; _Dbg_sig_print=()

# Should we reentry the debugger command loop on receiving the signal? 
# Each entry is "stop" or "nostop" or null.
typeset -a _Dbg_sig_stop; _Dbg_sig_stop=()

# Should we show a traceback on receiving the signal? 
# Each entry is "stack" or "nostack" or null.
typeset -a _Dbg_sig_show_stack; _Dbg_sig_show_stack=()

# Should pass the signal to the user program?? 
# Each entry is the trap handler with some variables substituted.
typeset -a _Dbg_sig_passthrough; _Dbg_sig_passthrough=()

# Should pass the signal to the user program?? 
# Each entry is the trap handler with some variables substituted.
typeset -i _Dbg_return_level=0

# Place to save values of $1, $2, etc.
typeset -a _Dbg_arg; _Dbg_arg=()

# Save value of handler variable _Dbg_old_$sig
_Dbg_save_handler() {
  typeset -r sig=$1
  typeset old_handler=''
  old_handler=$(trap -p $sig)
  if [[ -n $old_handler ]] ; then
    typeset -a old_hand_a
    old_hand_a=($old_handler)
    old_handler=$(_Dbg_subst_handler_var ${old_hand_a[2]})
    typeset -r decl_cmd="typeset -r _Dbg_old_${sig}_handler='$old_handler'"
    eval $decl_cmd
  fi
}

# Adjust handler variables to take into account the fact that when we
# call the handler we will have added another call before the user's
# handler.
_Dbg_subst_handler_var() {
    typeset -i i
    typeset result=''
    for arg in $* ; do 
	## FIXME: figure out what to do here. Something with
	## funcfiletrace and incrementing the index?
	# case $arg in 
	# '$LINENO' )
	#     arg='${BASH_LINENO[0]}'
	#     ;;
	# '${BASH_SOURCE[0]}' )
	#     arg='${BASH_SOURCE[1]}'
	#     ;;
	# '${FUNCNAME[0]}' )
	#     arg='${FUNCNAME[1]}'
	#     ;;
	# '${BASH_LINENO[0]}' )
	#     arg='${BASH_LINENO[1]}'
	#     ;;
	# esac
	if [[ $result == '' ]] ; then
	    result=$arg 
	else
	    result="$result $arg"
	fi
    done
    echo $result
}

# Debugger exit handler. Don't really exit - but go back the debugger 
# command loop
_Dbg_exit_handler() {

  # Consider putting the following line(s) in a routine.
  # Ditto for the restore environment
  typeset -i _Dbg_debugged_exit_code=$?

  # Turn off line and variable trace listing; allow unset parameter expansion.
  set +x +v +u

  if [[ ${_Dbg_sig_print[0]} == "print" ]] ; then 
    # Note: use the same message that gdb does for this.
    _Dbg_msg "Program received signal EXIT (0)..."
    if [[ ${_Dbg_sig_show_stack[0]} == "showstack" ]] ; then 
      _Dbg_do_backtrace 0
    fi
  fi

  if [[ $_Dbg_old_EXIT_handler != '' ]] ; then
    eval $_Dbg_old_EXIT_handler
  fi

  # If we've set the QUIT signal handler not to stop, or we've in the
  # middle of leaving so many (subshell) levels or we have set to
  # leave quietly on termination, then do it!

  if [[ ${_Dbg_sig_stop[0]} != "stop" ]] \
    || (( _Dbg_QUIT_LEVELS != 0 )) \
    || (( _Dbg_QUIT_ON_QUIT )) ; then 
    _Dbg_do_quit
    # We don't return from here.
  fi

  # We've tested for all the quitting conditions above.
  # Even though this is an exit handler, don't exit!

  typeset term_msg="normally"
  if [[ $_Dbg_debugged_exit_code != 0 ]] ; then 
    term_msg="with code $_Dbg_debugged_exit_code"
  fi

  # If we tried to exit from inside a subshell, we only want to enter
  # the command loop if don't have any pending subshells. 
  if (( ZSH_SUBSHELL == 0 )) ; then 
    _Dbg_msg \
      "Debugged program terminated $term_msg. Use q to quit or R to restart."

    _Dbg_running=0
    while : ; do
      _Dbg_process_commands
    done
  fi
}

# Generic signal handler. We consult global array _Dbg_sig_* for how
# to handle this signal.

# Since the command loop may be called we need to be careful about
# using variable names that would be exposed to the user. 
_Dbg_sig_handler() {

    # Consider putting the following line(s) in a routine.
    # Ditto for the restore environment
    typeset -i _Dbg_debugged_exit_code=$?
    _Dbg_old_set_opts=$-
  
    # Turn off line and variable trace listing if were not in our own debug
    # mode, and set our own PS4 for debugging inside the debugger
    (( !_Dbg_debug_debugger )) && set +x +v +u
    # shopt -s extdebug

    # This is the signal number. E.g. 15 is SIGTERM
    typeset -r -i _Dbg_signum=$1   

    if [[ ${_Dbg_sig_print[$_Dbg_signum]} == "print" ]] || \
        [[ ${_Dbg_sig_stop[$_Dbg_signum]} == "stop" ]] ; then
        typeset -r name=$(_Dbg_signum2name $_Dbg_signum)
        # Note: use the same message that gdb does for this.
        _Dbg_msg "Program received signal $name ($_Dbg_signum)..."
        if [[ ${_Dbg_sig_show_stack[$_Dbg_signum]} == "showstack" ]] ; then 
            _Dbg_stack_pos=0
            ((_Dbg_stack_size = ${#FUNCNAME[@]}))
            _Dbg_do_backtrace 
        fi
    fi
    if [[ ${_Dbg_sig_stop[$_Dbg_signum]} == "stop" ]] ; then

        ### The below duplicates what is above in _Dbg_debug_trap handler
        ### Should put common stuff into a function.
    
        shift  # signum

	_Dbg_arg=($@)   # Does this require shword split off? 

        _Dbg_set_debugger_entry
        _Dbg_hook_enter_debugger 'on receiving a signal' 'noprint'
	return $?
        # return $_Dbg_continue_rc

    elif (( _Dbg_sig_old_handler[_Dbg_signum] )) ; then
        eval ${_Dbg_sig_old_handler[$_Dbg_signum]}
    fi
    _Dbg_set_to_return_from_debugger 1
    return $_Dbg_debugged_exit_code
}

_Dbg_err_handler() {
    if [[ $_Dbg_old_ERR_handler != '' ]] ; then
	eval $_Dbg_old_ERR_handler
    fi
    _Dbg_msg "Error occured at ${funcfiletrace[1]}"
    _Dbg_process_commands
}

# Echo the name for a given signal number $1. The resulting name
# is in _Dbg_return
_Dbg_signum2name() {
    typeset -i -r signum=$1;
    builtin kill -l $signum 2>/dev/null
    return $?
}

# Return the signal number for a given signal name $1. The resulting number
# is in _Dbg_return
_Dbg_name2signum() {
    typeset -r signame=$1;
    builtin kill -l $signame 2>/dev/null
    return $?
}

_Dbg_subexit_handler() {
    # Read in the journal to pick up variable settings that might have
    # been left from a subshell.
    if [[ ${FUNCNAME[1]} == _Dbg_* ]] && (( !_Dbg_debug_debugger )); then
	return 0
    fi
    _Dbg_source_journal
    if (( _Dbg_QUIT_LEVELS > 0 )) ; then
	_Dbg_do_quit $_Dbg_debugged_exit_code
    fi
}

# Set up generic trap handler. Arguments are: 
# NAME print showstack stop passthrough
_Dbg_init_trap() {
    typeset -r name=$1
    typeset -i -r signum=$(_Dbg_name2signum $name)
    
    _Dbg_sig_print[$signum]=$2;
    _Dbg_sig_show_stack[$signum]=${3:-'nostack'};
    _Dbg_sig_stop[$signum]=${4:-'nostop'};
    
    # Work out passthrough later...
    # if [[ $5 == "pass*" ]] ; then
    #  get existing trap from env.
    #  _Dbg_sig_show_passthrough[$signum]=....;
    #

    if (( signum == 0 )) ; then
	trap '_Dbg_exit_handler "$ZSH_DEBUG_COMMAND"' EXIT
    else
	typeset trap_cmd="trap '_Dbg_sig_handler $signum \"\$ZSH_DEBUG_COMMAND\" \"\$@\"' $name"
	eval $trap_cmd
    fi
}

_Dbg_init_default_traps() {
    # _Dbg_init_trap EXIT   "noprint" "nostack" "stop" 
    _Dbg_init_trap ILL    "print" "showstack" "stop" 
    _Dbg_init_trap INT    "print" "showstack" "stop" 
    _Dbg_init_trap QUIT   "print" "showstack" "stop" 
    _Dbg_init_trap TERM   "print" "showstack" "stop" 
    # _Dbg_init_trap TRAP   "print" "showstack" "stop" 
}
