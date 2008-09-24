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

typeset _Dbg_prompt_str='$_Dbg_debugger_name${_Dbg_less}%h${_Dbg_greater}'

# The canonical name of last command run.
typeset _Dbg_last_cmd=''

typeset last_next_step_cmd='s' # Default is step.

typeset _Dbg_last_print=''     # expression on last print command
typeset _Dbg_last_printe=''    # expression on last print expression command

# A list of debugger command input-file descriptors.
# Duplicate standard input
typeset -i _Dbg_fdi ; exec {_Dbg_fdi}<&0

# Save descriptor number
typeset -a _Dbg_fd ; _Dbg_fd=("$_Dbg_fdi")

# A list of source'd command files. If the entry is '', then we are 
# interactive.
typeset -a _Dbg_cmdfile ; _Dbg_cmdfile=('')

# ===================== FUNCTIONS =======================================

# Note: We have to be careful here in naming "local" variables. In contrast
# to other places in the debugger, because of the read/eval loop, they are
# in fact seen by those using the debugger. So in contrast to other "local"s
# in the debugger, we prefer to preface these with _Dbg_.
function _Dbg_process_commands {

  # Nuke any prior step-ignore counts
  _Dbg_write_journal_eval "_Dbg_step_ignore=-1"

  # Evaluate all the display expressions
  ## _Dbg_eval_all_display

  # Loop over all pending open input file descriptors
  while (( ${#_Dbg_fd[@]} > 0 )) ; do

      _Dbg_fdi=${_Dbg_fd[-1]}
      # Set up prompt to show shell and subshell levels.
      typeset _Dbg_greater='>'
      typeset _Dbg_less='<'
      typeset result  # Used by copies to return a value.
      
      if _Dbg_copies ')' $ZSH_SUBSHELL ; then
	  _Dbg_greater="${result}${_Dbg_greater}"
	  _Dbg_less="${_Dbg_less}${result//)/(}"
      fi
      
      typeset _Dbg_prompt
      eval "_Dbg_prompt=\"$_Dbg_prompt_str \""
      _Dbg_prompt=$(print -R "$_Dbg_prompt")
      _Dbg_preloop
      typeset _Dbg_cmd 
      typeset line=''
      while : ; do
	  if [[ -t $_Dbg_fdi ]]; then
	      if ((_Dbg_history_save)) && [[ -r $_Dbg_histfile ]] ; then 
		  fc -ap $_Dbg_histfile $_Dbg_history_length $_Dbg_history_length
	      fi
	      vared -e -h -p "$_Dbg_prompt" line <&${_Dbg_fdi} || break
	  else
	      read "?$_Dbg_prompt" line <&${_Dbg_fdi} || break
	  fi
          _Dbg_onecmd "$line"
          rc=$?
          _Dbg_postcmd
	  (( $rc >= 0 )) && print -s -- "$line"
          (( $rc > 0 ))  && return $rc
	  
	  line=''
      done # read "?$_Dbg_prompt" ...
      
      _Dbg_fd[-1]=()  # Remove last element
      (( ${#_Dbg_fd[@]} <= 0 )) && break
  done

  # EOF hit. Same as quit without arguments
  _Dbg_msg '' # Cause <cr> since EOF may not have put in.
  _Dbg_do_quit
}

# Run a debugger command "annotating" the output
_Dbg_annotation() {
  local label=$1
  shift
  _Dbg_do_print "$label"
  $*
  _Dbg_do_print  ''
}

# Run a single command
# Parameters: _Dbg_cmd and args
# 
_Dbg_onecmd() {

    # setopt shwordsplit ksharrays  # Done in _Dbg_debug_trap_handler
    typeset full_cmd
    full_cmd="$*"
    typeset _Dbg_cmd
    typeset args
    set -- $*
    if (( $# == 0 )) ; then
	_Dbg_cmd=$_Dbg_last_next_step_cmd
	args=$_Dbg_last_next_step_args
    else
	_Dbg_cmd=$1
	shift
	args="$*"
    fi
    typeset expanded_alias; _Dbg_alias_expand $_Dbg_cmd
    typeset _Dbg_cmd="$expanded_alias"

    # If "set trace-commands" is "on", echo the the command
    if [[  $_Dbg_trace_commands == 'on' ]]  ; then
      _Dbg_msg "+$_Dbg_cmd $args"
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

	# Set breakpoint on a line
	break )
	  _Dbg_do_break 0 $args 
	  _Dbg_last_cmd="break"
	  ;;

# 	# Delete all breakpoints by line number.
# 	clear )
# 	  _Dbg_do_clear_brkpt $args
# 	  _Dbg_last_cmd='clear'
# 	  ;;

	# Continue
	continue )
	  
	  _Dbg_last_cmd='continue'
	  if _Dbg_do_continue $@ ; then
	    # _Dbg_write_journal_eval \
	    #  "_Dbg_old_set_opts=\"$_Dbg_old_set_opts -o functrace\""
	    return 1
	  fi
	  ;;

	# Delete breakpoints by entry numbers. 
	delete )
	  _Dbg_do_delete $args
	  _Dbg_last_cmd='delete'
	  ;;

	# Disable breakpoints
	disable )
	  _Dbg_do_disable $args
	  _Dbg_last_cmd='disable'
	  ;;

	# Move call stack down
	down )
	  _Dbg_do_down $@
	  _Dbg_last_cmd='down'
	  ;;

	# edit file currently positioned at
	edit )
	  _Dbg_do_edit $args
	  _Dbg_last_cmd='edit'
	  ;;

	# enable breakpoints or watchpoints
	enable )
	  _Dbg_do_enable $args
	  _Dbg_last_cmd='enable'
	  ;;

	# evaluate as shell command
	eval )
	  _Dbg_do_eval $@
	  _Dbg_last_cmd='eval'
	  ;;

	# intelligent print of variable, function or expression
	examine )
	  _Dbg_do_examine "$args"
	  ;;

	#  Set stack frame
	frame )
	  _Dbg_do_frame $@
	  _Dbg_last_cmd='frame'
	  ;;

	# print help command menu
	help )
	  _Dbg_do_help $args ;;

	#  Info subcommands
	info )
	  _Dbg_do_info $args ;;

	# List line.
	# print lines in file
	l | li | lis | list )
	  _Dbg_do_list $args
	  _Dbg_last_cmd='list'
	  ;;

	# single-step ignoring functions
	'next+' | 'next-' | 'next' )
	  _Dbg_do_next "$_Dbg_cmd" $@
	  return $?
	  ;;

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

	# skip N times (default 1)
	sk | ski | skip )
	  _Dbg_last_cmd='skip'
	  _Dbg_do_skip $@ && return 2
	  ;;

	# Run a debugger command file
	source )
	  _Dbg_last_cmd='source'
	  _Dbg_do_source $@
	  ;;

	# restart debug session.
	run )
	  _Dbg_last_cmd='run'
	  _Dbg_do_run $args
	  ;;

	# Command to set debugger options
	set )
	  _Dbg_do_set $args
	  _Dbg_last_cmd='set'
	  ;;

	# Command to show debugger settings
	show )
	  _Dbg_do_show $args
	  _Dbg_last_cmd='show'
	  ;;

	# single-step 
	'step+' | 'step-' | 'step' )
	  _Dbg_do_step "$_Dbg_cmd" $@
	  return $?
	  ;;

	# Set a one-time breakpoint
	tbreak )
	  _Dbg_do_break 1 $args 
	  _Dbg_last_cmd='tbreak'
	  ;;

	# Trace a function
	trace )
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

	where )
	  _Dbg_do_backtrace $@
	  ;;

	'' )
	  # Redo last_cmd
	  if [[ -n $_Dbg_last_cmd ]] ; then 
	      _Dbg_cmd=$_Dbg_last_cmd 
	      _Dbg_redo=1
	  fi
	  ;;

	# List all breakpoints and actions.
	L )
	  _Dbg_do_list_brkpt
	  # _Dbg_list_watch
	  # _Dbg_list_action
	  ;;

	* ) 
	   if (( _Dbg_autoeval )) ; then
	     ! _Dbg_do_eval $_Dbg_cmd $args && return -1
	   else
             _Dbg_msg "Undefined command: \"$_Dbg_cmd\". Try \"help\"." 
	     return -1
	   fi
	  ;;
      esac
      return 0
}

_Dbg_preloop() {
  if (($_Dbg_annotate)) ; then
      _Dbg_annotation 'breakpoints' _Dbg_do_info breakpoints
      # _Dbg_annotation 'locals'      _Dbg_do_backtrace 3 
      _Dbg_annotation 'stack'       _Dbg_do_backtrace 3 
  fi
}

_Dbg_postcmd() {
  if (($_Dbg_annotate)) ; then
      case $_Dbg_last_cmd in
        break | tbreak | disable | enable | condition | clear | delete ) 
	  _Dbg_annotation 'breakpoints' _Dbg_do_info breakpoints
        ;;
	up | down | frame ) 
	  _Dbg_annotation 'stack' _Dbg_do_backtrace 3
	;;
      * )
      esac
  fi
}

