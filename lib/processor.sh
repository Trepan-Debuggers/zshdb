# -*- shell-script -*-
# dbg-processor.sh - Top-level debugger commands
#
#   Copyright (C) 2008, 2009, 2010, 2011
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

# Are we inside the middle of a "skip" command?
typeset -i  _Dbg_inside_skip=0

# Hooks that get run on each command loop
typeset -A _Dbg_cmdloop_hooks
_Dbg_cmdloop_hooks['display']='_Dbg_eval_all_display'

typeset _Dbg_prompt_str='$_Dbg_debugger_name${_Dbg_less}$_Dbg_cmd_num${_Dbg_greater}'

# The canonical name of last command run.
typeset _Dbg_last_cmd=''

# Command currently under consideration, without any alias expansion.
typeset _Dbg_cmd=''

# Command number shown in prompt, e.g. 1 in zshdb<1>
typeset -i _Dbg_cmd_num=0

typeset last_next_step_cmd='s' # Default is step.

typeset _Dbg_last_print=''     # expression on last print command
typeset _Dbg_last_printe=''    # expression on last print expression command

# To keep us from recursively calling vared.
typeset -i _Dbg_in_vared=0

# A list of debugger command input-file descriptors.
# Duplicate standard input. Note we need to export it as well.
typeset -xi _Dbg_fdi ;

# Save descriptor number
typeset -a _Dbg_fd ; _Dbg_fd=()

# A list of source'd command files. If the entry is '', then we are
# interactive.
typeset -a _Dbg_cmdfile ; _Dbg_cmdfile=('')

# The main debugger command reading loop.
#
# Note: We have to be careful here in naming "local" variables. In contrast
# to other places in the debugger, because of the read/eval loop, they are
# in fact seen by those using the debugger. So in contrast to other "local"s
# in the debugger, we prefer to preface these with _Dbg_.
function _Dbg_process_commands {

  # initial debugger input source from zshdb arguments
  if [[ ! -z "$_Dbg_tty_in" ]] && [[  -r "$_Dbg_tty_in" ]]
  then
    exec {_Dbg_fdi}<$_Dbg_tty_in
    _Dbg_fd[++_Dbg_fd_last]=$_Dbg_fdi
    _Dbg_cmdfile+=("$_Dbg_tty_in")
  fi

  _Dbg_continue_rc=-1  # Don't continue execution unless told to do so.
  # Nuke any prior step-ignore counts
  _Dbg_write_journal_eval "_Dbg_step_ignore=-1"
  _Dbg_hi_last_stop=-1

  typeset -l key

  # Evaluate all hooks
  for hook in ${_Dbg_cmdloop_hooks[@]} ; do
      ${hook}
  done

  _Dbg_prompt_output="${_Dbg_tty:-/dev/null}"

  # Loop over all pending open input file descriptors
  while (( ${#_Dbg_fd[@]} > 0 )) ; do

      _Dbg_fdi=${_Dbg_fd[-1]}

      # Set up prompt to show shell and subshell levels.
      typeset _Dbg_greater=''
      typeset _Dbg_less=''

      # Used by copies to return a value. /dev/null because zsh prints
      # a definition if it has been defined before? So why not
      # needed for _Dbg_less and _Dbg_greater ?
      typeset result 1>/dev/null

      if _Dbg_copies '>' $_Dbg_DEBUGGER_LEVEL ; then
	  _Dbg_greater=$result
	  _Dbg_copies '<' $_Dbg_DEBUGGER_LEVEL
      	  _Dbg_less=$result
      fi

      if _Dbg_copies ')' $ZSH_SUBSHELL ; then
	  _Dbg_greater="${result}${_Dbg_greater}"
	  _Dbg_less="${_Dbg_less}${result//)/(}"
      fi

      # typeset _Dbg_prompt
      if [[ -n $_Dbg_set_highlight ]] ; then
	      eval "_Dbg_prompt=\"${_Dbg_ansi_term_underline}$_Dbg_prompt_str${_Dbg_ansi_term_normal} \"" 2>/dev/null
      else
	  eval "_Dbg_prompt=\"$_Dbg_prompt_str \"" 2>/dev/null
      fi
      _Dbg_preloop
      # typeset _Dbg_cmd
      typeset line=''
      typeset -i rc
      while : ; do
	  ((_Dbg_cmd_num++))
	  if ((0 == _Dbg_in_vared)) && [[ -t $_Dbg_fdi ]]; then
	      _Dbg_in_vared=1
	      vared -e -h -p "$_Dbg_prompt" line 2>>$_Dbg_prompt_output <&${_Dbg_fdi} || break
	      _Dbg_in_vared=0
	  else
	      if ((1 == _Dbg_in_vared)) ; then
		   _Dbg_msg "Unable to echo characters in input below"
	      fi
	      if [[ -z ${_Dbg_cmdfile[-1]} ]] ; then
		   read -u ${_Dbg_fdi} "?$_Dbg_prompt" line 2>>$_Dbg_prompt_output || break
	      else
		   read -u ${_Dbg_fdi}  line || break
	      fi
	  fi
      _Dbg_onecmd "$line"
      rc=$?
      _Dbg_postcmd
	  ((_Dbg_continue_rc >= 0)) && return $_Dbg_continue_rc

	  # Add $line to the debugger history file unless there was an
	  # error or the line was empty. Command "print -s" is what
	  # does this. Obvious, right?
	  if [[ -n $line ]] && (( rc >= 0 )) ; then
	      if [[ -z ${_Dbg_cmdfile[-1]} ]]; then
		  _Dbg_write_journal "((\$ZSH_SUBSHELL < $ZSH_SUBSHELL)) && print -s -- \"$line\""
		  print -s -- "$line"
	      else
		  print -s -- "$line" > /dev/null
	      fi
	      if ((_Dbg_history_save)) && [[ -n $_Dbg_histfile ]]; then
		  fc -W ${_Dbg_histfile} ${_Dbg_history_length}
	      fi
	  fi

      (( rc > 0 )) && return $rc

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
  typeset label="$1"
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
    full_cmd=$@
    typeset args
    set -- $*
    if (( $# == 0 )) ; then
	_Dbg_cmd=$_Dbg_last_next_step_cmd
	args=$_Dbg_last_next_step_args
    else
	_Dbg_cmd=$1
	shift
	args="$@"
    fi
    typeset _Dbg_orig_cmd;
    _Dbg_orig_cmd=$_Dbg_cmd
    typeset expanded_alias; _Dbg_alias_expand $_Dbg_cmd

    # If "set trace-commands" is "on", echo the the command
    if [[  $_Dbg_set_trace_commands == 'on' ]]  ; then
      _Dbg_msg "+$_Dbg_cmd $args"
    fi

    if [[ -n ${_Dbg_debugger_commands[$expanded_alias]} ]] ; then
      ${_Dbg_debugger_commands[$expanded_alias]} $args
      return $?
    fi

    # The below are command names that are just a little irregular
    case $_Dbg_cmd in
	[#]* )
	  _Dbg_last_cmd="#"
	  # _Dbg_remove_history_item
	  return -1 # don't put in history.
	  ;;

	# single-step ignoring functions
	'next+' | 'next-' )
	  _Dbg_do_next $@
	  return $?
	  ;;

	# single-step
	'step+' | 'step-' )
	  _Dbg_do_step $@
	  return $?
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
	  _Dbg_do_info_breakpoints
	  # _Dbg_list_watch
	  _Dbg_list_action
	  ;;

	# Remove all actions
	A )
	  _Dbg_do_clear_all_actions $args
	  ;;

	* )
	   if (( _Dbg_set_autoeval )) ; then
	       if [[ -t $_Dbg_fdi ]] ; then
		   if ! _Dbg_do_eval $_Dbg_cmd $args >>"$_Dbg_tty" 2>&1 ; then
		       return -1
		   fi
	       else
		   if ! _Dbg_do_eval $_Dbg_cmd $args ; then
		       return -1
		   fi
	       fi
	   else
             _Dbg_undefined_cmd $_Dbg_cmd
	     return -1
	   fi
	  ;;
      esac
      return 0
}

_Dbg_preloop() {
    if ((_Dbg_set_annotate)) ; then
	_Dbg_annotation 'breakpoints' _Dbg_do_info breakpoints
	# _Dbg_annotation 'locals'      _Dbg_do_backtrace 3
	_Dbg_annotation 'stack'       _Dbg_do_backtrace 3
    fi
}

_Dbg_postcmd() {
    if ((_Dbg_set_annotate)) ; then
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
