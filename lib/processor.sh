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

# ==================== VARIABLES =======================================
# Are we inside the middle of a "skip" command?
typeset -i  _Dbg_inside_skip=0

typeset _Dbg_prompt_str="$_Dbg_debugger_name<1> "

# The canonical name of last command run.
typeset _Dbg_last_cmd=''

# ==================== VARIABLES =======================================
# _Dbg_INPUT_START_DESC is the lowest descriptor we use for reading.
# _Dbg_MAX_INPUT_DESC   is the maximum input descriptor that can be 
#                       safely used (as per the bash manual on redirection)
# _Dbg-input_desc       is the current descriptor in use. "sourc"ing other
#                       command files will increase this descriptor

typeset -ir _Dbg_INPUT_START_DESC=4
typeset -i  _Dbg_MAX_INPUT_DESC=9  # logfile can reduce this
typeset -i  _Dbg_input_desc=_Dbg_INPUT_START_DESC # ++ before use

typeset _Dbg_redirect_cmd="exec $_Dbg_input_desc<&0"
eval $_Dbg_redirect_cmd

# keep a list of source'd command files. If the entry is '', then we are 
# interactive.
typeset -a _Dbg_cmdfile
_Dbg_cmdfile=('')

# List of command files to process
typeset -a _Dbg_input

# ===================== FUNCTIONS =======================================

# Note: We have to be careful here in naming "local" variables. In contrast
# to other places in the debugger, because of the read/eval loop, they are
# in fact seen by those using the debugger. So in contrast to other "local"s
# in the debugger, we prefer to preface these with _Dbg_.
function _Dbg_process_commands {

  # Evaluate all the display expressions
  ## _Dbg_eval_all_display

  # Evaluate all the display expressions
  # _Dbg_eval_all_display

  # Loop over all pending open input file descriptors
  while (( $_Dbg_input_desc >= $_Dbg_INPUT_START_DESC )) ; do

    typeset _Dbg_prompt="$_Dbg_prompt_str"
    # _Dbg_preloop
    typeset _Dbg_cmd 
    typeset args
    while read "?$_Dbg_prompt" _Dbg_cmd args <&$_Dbg_input_desc
    do
    	_Dbg_onecmd "$_Dbg_cmd" "$args"
        rc=$?
        # _Dbg_postcmd
        (( $rc != 0 )) && return $rc
    done # read "?$_Dbg_prompt" ...

    ((_Dbg_input_desc--))
    if (( $_Dbg_input_desc >= $_Dbg_INPUT_START_DESC )) ; then
      _Dbg_redirect_cmd="exec $_Dbg_input_desc<&0"
      eval $_Dbg_redirect_cmd
    fi

  done
  # EOF hit. Same as quit without arguments
  _Dbg_msg '' # Cause <cr> since EOF may not have put in.
  _Dbg_do_quit
}

# Run a single command
# Parameters: _Dbg_cmd and args
# 
_Dbg_onecmd() {
    typeset expanded_alias; _Dbg_alias_expand $1
    typeset _Dbg_cmd="$expanded_alias"
    eval "set -- $2"

    # Set default next, step or skip command
    if [[ -z $_Dbg_cmd ]]; then
	_Dbg_cmd=$_Dbg_last_next_step_cmd
	args=$_Dbg_last_next_step_args
    fi
    
    case $_Dbg_cmd in
	# Comment line
	[#]* ) 
	  # _Dbg_remove_history_item
	  _Dbg_last_cmd="#"
	  ;;

	alias )
	  _Dbg_do_alias $@
	  ;;

	where )
	  _Dbg_do_backtrace $@
	  ;;

	# Continue
	c | cont | conti |contin |continu | continue )
	  
	  _Dbg_last_cmd='continue'
	  if _Dbg_do_continue $@ ; then
	    # _Dbg_write_journal_eval \
	    #  "_Dbg_old_set_opts=\"$_Dbg_old_set_opts -o functrace\""
	    return 1
	  fi
	  ;;

	# Move call stack down
	do | dow | down )
	  _Dbg_do_down $@
	  _Dbg_last_cmd='down'
	  ;;

	# edit file currently positioned at
	edit )
	  _Dbg_do_edit $args
	  _Dbg_last_cmd='edit'
	  ;;

	# evaluate as shell command
	eval )
	  _Dbg_do_eval $@
	  _Dbg_last_cmd='eval'
	  ;;

	#  Set stack frame
	fr | fra | fra | frame )
	  _Dbg_do_frame $@
	  _Dbg_last_cmd='frame'
	  ;;

	# print help command menu
	help )
	  _Dbg_do_help $args ;;

	# print globbed or substituted variables
	print )
	  _Dbg_do_print "$args"
	  _Dbg_last_cmd='print'
	  ;;

	# quit
	quit )
	  _Dbg_last_cmd='quit'
	  _Dbg_do_quit $@
	  ;;

	# single-step N times (default 1)
	step )
	  _Dbg_last_next_step_cmd="$_Dbg_cmd"
	  _Dbg_last_next_step_args="$@"
	  _Dbg_do_step $@
	  return $?
	  ;;

# 	# skip N times (default 1)
# 	sk | ski | skip )
# 	  _Dbg_last_cmd='skip'
# 	  _Dbg_do_skip $@
# 	  return $?
# 	  ;;

	# Run a debugger comamnd file
	so | sou | sour | sourc | source )
	  _Dbg_last_cmd='source'
	  _Dbg_do_source $@
	  ;;

	# restart debug session.
	ru | run )
	  _Dbg_last_cmd='run'
	  _Dbg_do_run $args
	  ;;

	# Trace a function
	tr | tra | tra | trac | trace )
	  _Dbg_do_trace_fn $args 
	  ;;

	# Move call stack up
	up )
	  _Dbg_do_up $args
	  _Dbg_last_cmd='up'
	  ;;

	# Remove a function trace
	unt | untr | untra | untrac | untrace )
	  _Dbg_do_untrace_fn $args 
	  ;;

	'' )
	  # Redo last_cmd
	  if [[ -n $_Dbg_last_cmd ]] ; then 
	      _Dbg_cmd=$_Dbg_last_cmd 
	      _Dbg_redo=1
	  fi
	  ;;

	* ) 
	   if (( _Dbg_autoeval )) ; then
	     _Dbg_do_eval $_Dbg_cmd $args
	   else
             _Dbg_msg "Undefined command: \"$_Dbg_cmd\". Try \"help\"." 
	     # _Dbg_remove_history_item
	     # typeset -a last_history=(`history 1`)
	     # history -d ${last_history[0]}
	   fi
	  ;;
      esac
      return 0
}
