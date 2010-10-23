# -*- shell-script -*-
# help.sh - Debugger Help Routines
#   Copyright (C) 2008, 2010 Rocky Bernstein rocky@gnu.org
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

# A place to put help command text
typeset -A _Dbg_command_help
export _Dbg_command_help

# Add help text $2 for command $1
function _Dbg_help_add {
    (($# != 2)) && return 1
     _Dbg_command_help[$1]="$2"
     return 0
}

typeset _Dbg_set_cmds="args annotate autoeval autolist basename debugger 
different inferior-tty linetrace listsize prompt trace-commands width"

_Dbg_help_set() {

  if (( $# == 0 )) ; then 
      typeset thing
      for thing in $_Dbg_set_cmds ; do 
	_Dbg_help_set $thing 1
      done
      return 0
  fi

  typeset set_cmd="$1"
  typeset label="$2"

  case $set_cmd in 
      ar | arg | args )
	  [[ -n $label ]] && label='set args -- '
	  _Dbg_msg \
	      "${label}Set argument list to give program being debugged when it is started.
Follow this command with any number of args, to be passed to the program."
	  return 0
	  ;;
      an | ann | anno | annot | annota | annotat | annotate )
	  if [[ -n $label ]] ; then 
	      label='set annotate  -- '
	  else
	      typeset post_label='
0 == normal;     1 == fullname (for use when running under emacs).'
	  fi
	  _Dbg_msg \
	      "${label}Set annotation level.$post_label"
	  return 0
	  ;;
      autoe | autoev | autoeva | autoeval )
	  _Dbg_help_set_onoff 'autoeval' 'autoeval' \
	      "Evaluate unrecognized commands"
	  return 0
	  ;;
      autol | autoli | autolis | autolist )
	  [[ -n $label ]] && label='set autolist  -- '
	  typeset -l onoff="on."
	  [[ -z ${_Dbg_cmdloop_hooks['list']} ]] && onoff='off.'
	  _Dbg_msg \
	      "${label}Run list command is ${onoff}"
	  return 0
	  ;;
      b | ba | bas | base | basen | basena | basenam | basename )
	  _Dbg_help_set_onoff 'basename' 'basename' \
	      "Set short filenames (the basename) in debug output"
	  return 0
	  ;;
      deb|debu|debug|debugg|debugger|debuggi|debuggin|debugging )
	  _Dbg_help_set_onoff 'debugging' 'debugging' \
	      "Set debugging the debugger"
	  return 0
	  ;;
      force | dif | diff | differ | different )
	  _Dbg_help_set_onoff 'different' 'different' \
	      "Set stepping forces a different line"
	  return 0
	  ;;
      inferior-tty )
	  [[ -n $label ]] && label='set inferior-tty -- '
	  _Dbg_msg "${label} set tty for input and output"
	  ;;
      lin | line | linet | linetr | linetra | linetrac | linetrace )
	  [[ -n $label ]] && label='set linetrace -- '
	  typeset onoff='off.'
	  (( $_Dbg_linetrace )) && onoff='on.'
	  _Dbg_msg \
	      "${label}Set tracing execution of lines before executed is" $onoff
	  if (( $_Dbg_linetrace )) ; then
	      _Dbg_msg \
		  "set linetrace delay -- delay before executing a line is" $_Dbg_linetrace_delay
	  fi
	  return 0
	  ;;
      lis | list | lists | listsi | listsiz | listsize )
	  [[ -n $label ]] && label='set listsize  -- '
	  _Dbg_msg \
	      "${label}Set number of source lines $_Dbg_debugger_name will list by default."
	  ;;
      p | pr | pro | prom | promp | prompt )
	  [[ -n $label ]] && label='set prompt    -- '
	  _Dbg_msg \
	      "${label}${_Dbg_debugger_name}'s prompt is:\n" \
	      "      \"$_Dbg_prompt_str\"."
	  return 0
	  ;;
      sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
	  [[ -n $label ]] && label='set showcommand -- '
	  _Dbg_msg \
	      "${label}Set showing the command to execute is $_Dbg_show_command."
	  return 0
	  ;;
      t|tr|tra|trac|trace|trace-|tracec|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
	  [[ -n $label ]] && label='set trace-commands -- '
	  _Dbg_msg \
	      "${label}Set showing debugger commands is $_Dbg_set_trace_commands."
	  return 0
	  ;;
      w | wi | wid | widt | width )
	  [[ -n $label ]] && label='set width          -- '
	  _Dbg_msg \
	      "${label}Set line length to use in output."
	  ;;
      * )
	  _Dbg_msg \
	      "There is no \"set $set_cmd\" command."
  esac
}

typeset _Dbg_show_cmds="aliases annotate args autoeval autolist basename commands 
copying directories debugger force linetrace listsize prompt trace-commands warranty"

_Dbg_help_show() {
  typeset show_cmd=$1

  if [[ -z $show_cmd ]] ; then 
      typeset thing
      for thing in $_Dbg_show_cmds ; do 
	_Dbg_help_show $thing 1
      done
      return
  fi

  case $show_cmd in 
    al | ali | alia | alias | aliase | aliases )
      _Dbg_msg \
'show aliases     -- Show list of aliases currently in effect.'
      return 0
      ;;
    ar | arg | args )
      _Dbg_msg \
'show args        -- Show argument list to give program being debugged when it 
                    is started.'
      return 0
      ;;
    an | ann | anno | annot | annota | annotat | annotate )
      _Dbg_msg \
"show annotate    -- Show annotation_level"
      return 0
      ;;
    autoe | autoev | autoeva | autoeval )
      _Dbg_msg \
'show autoeval    -- Show if we evaluate unrecognized commands.'
      return 0
      ;;
    autol | autoli | autolis | autolist )
       _Dbg_msg \
"show autolist    -- Run list before command loop?"
       return 0
       ;;
    b | ba | bas | base | basen | basena | basenam | basename )
      _Dbg_msg \
'show basename    -- Show if we are are to show short or long filenames.'
      return 0
      ;;
    com | comm | comma | comman | command | commands )
      _Dbg_msg \
'show commands    -- Show the history of commands you typed.'
      ;;
    cop | copy| copyi | copyin | copying )
      _Dbg_msg \
'show copying     -- Conditions for redistributing copies of debugger.'
     ;;
    d|de|deb|debu|debug|debugg|debugger|debuggi|debuggin|debugging )
     _Dbg_msg \
'show debugger    -- Show if we are set to debug the debugger.'
      return 0
      ;;
    different | force)
      _Dbg_msg \
'show different   -- Show if setting forces a different line.'
      ;;
    dir|dire|direc|direct|directo|director|directori|directorie|directories)
      _Dbg_msg \
"show directories -- Show file directories searched for listing source."
      ;;
    lin | line | linet | linetr | linetra | linetrac | linetrace )
      _Dbg_msg \
'show linetrace   -- Show whether to trace lines before execution.'
      ;;
    lis | list | lists | listsi | listsiz | listsize )
      _Dbg_msg \
'show listsize    -- Show number of source lines debugger will list by default.'
      ;;
    p | pr | pro | prom | promp | prompt )
      _Dbg_msg \
"show prompt      -- Show debugger's prompt."
      return 0
      ;;
    t|tr|tra|trac|trace|trace-|trace-c|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
      _Dbg_msg \
'show trace-commands -- Show if we are echoing debugger commands'
      return 0
      ;;
    w | wa | war | warr | warra | warran | warrant | warranty )
      _Dbg_msg \
'show warranty    -- Various kinds of warranty you do not have.'
      return 0
      ;;
    * )
      _Dbg_msg \
    "Undefined show command: \"$show_cmd\".  Try \"help show\"."
  esac
}

