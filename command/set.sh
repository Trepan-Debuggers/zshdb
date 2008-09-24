# -*- shell-script -*-
# set.sh - debugger settings
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

# Sets whether or not to display command to be executed in debugger prompt.
# If yes, always show. If auto, show only if the same line is to be run
# but the command is different.

# Set initial line tracing flag off
typeset -i _Dbg_linetrace=0 
typeset -i _Dbg_linewidth; _Dbg_linewidth=${COLUMNS:-80} 
typeset -i _Dbg_linetrace_expand=0 # expand variables in linetrace output
typeset    _Dbg_linetrace_delay=1  # sleep after linetrace

typeset -i _Dbg_autoeval=0     # Evaluate unrecognized commands?
typeset -i _Dbg_listsize=10    # How many lines in a listing? 

# Sets whether or not to display command before executing it.
typeset _Dbg_trace_commands='off'

_Dbg_help_add set ''  # Help routine is elsewhere

_Dbg_do_set() {
  typeset set_cmd=$1
  if [[ $set_cmd == '' ]] ; then
    _Dbg_msg "Argument required (expression to compute)."
    return;
  fi
  shift
  case $set_cmd in 
    ar | arg | args )
      # We use the loop below rather than _Dbg_set_args="(@)" because
      # we want to preserve embedded blanks in the arguments.
      _Dbg_script_args=()
      typeset -i i
      typeset -i n=$#
      for (( i=0; i<n ; i++ )) ; do
	_Dbg_write_journal_eval "_Dbg_script_args[$i]=$1"
	shift
      done
      ;;
    an | ann | anno | annot | annota | annotat | annotate )
      if (( $# == 0 )) ; then
	  _Dbg_msg "Argument required (an integer to set 'annotate' to.)."
      elif [[ $1 == [0-9]* ]] ; then 
	if (( $1 > 3 || $1 < 0)); then
	    _Dbg_msg "Annotation level must be between 0 and 3. Got: ${1}."
	else
	    _Dbg_write_journal_eval "_Dbg_annotate=$1"
	fi
      else
	_Dbg_msg "Integer argument expected; got: $1"
	return 1
      fi
      return 0
      ;;
    au | aut | auto | autoe | autoev | autoeva | autoeval )
      typeset onoff=${1:-'off'}
      case $onoff in 
	on | 1 ) 
	  _Dbg_write_journal_eval "_Dbg_autoeval=1"
	  ;;
	off | 0 )
	  _Dbg_write_journal_eval "_Dbg_autoeval=0"
	  ;;
	* )
	  _Dbg_msg "\"on\" or \"off\" expected."
	  return 1
      esac
      return 0
      ;;
    b | ba | bas | base | basen | basena | basenam | basename )
      typeset onoff=${1:-'off'}
      case $onoff in 
	on | 1 ) 
	  _Dbg_write_journal_eval "_Dbg_basename_only=1"
	  ;;
	off | 0 )
	  _Dbg_write_journal_eval "_Dbg_basename_only=0"
	  ;;
	* )
	  _Dbg_msg "\"on\" or \"off\" expected."
	  return 1
      esac
      return 0
      ;;
    d|de|deb|debu|debug|debugg|debugger|debuggi|debuggin|debugging )
      typeset onoff=${1:-'on'}
      case $onoff in 
	on | 1 ) 
	  _Dbg_write_journal_eval "_Dbg_debug_debugger=1"
	  ;;
	off | 0 )
	  _Dbg_write_journal_eval "_Dbg_debug_debugger=0"
	  ;;
	* )
	  _Dbg_msg "\"on\" or \"off\" expected."
      esac
      ;;
    e | ed | edi | edit | editi | editin | editing )
      typeset onoff=${1:-'on'}
      case $onoff in 
	e | em | ema | emac | emacs ) 
	  _Dbg_edit='-e'
	  _Dbg_edit_style='emacs'
	  builtin bindkey -e 
	  ;;
	on | 1 ) 
	  _Dbg_edit='-e'
	  _Dbg_edit_style='emacs'
	  builtin bindkey -e
	  ;;
	off | 0 )
	  _Dbg_edit=''
	  return 0
	  ;;
	v | vi ) 
	  _Dbg_edit='-e'
	  _Dbg_edit_style='vi'
	  builtin bindkey -v 
	  ;;
	* )
	  _Dbg_errmsg '"on", "off", "vi", or "emacs" expected.'
	  return 1
      esac
      ;;
    force )
      typeset onoff=${1:-'off'}
      case $onoff in 
	on | 1 ) 
	  _Dbg_write_journal_eval "_Dbg_step_auto_force=1"
	  ;;
	off | 0 )
	  _Dbg_write_journal_eval "_Dbg_step_auto_force=0"
	  ;;
	* )
	  _Dbg_msg "\"on\" or \"off\" expected."
	  return 1
      esac
      return 0
      ;;
   hi|his|hist|histo|histor|history)
      case $1 in 
	sa | sav | save )
	  typeset onoff=${2:-'on'}
	  case $onoff in 
	    on | 1 ) 
	      _Dbg_write_journal_eval "_Dbg_history_save=1"
	      ;;
	    off | 0 )
	      _Dbg_write_journal_eval "_Dbg_history_save=0"
	      ;;
	    * )
	      _Dbg_msg "\"on\" or \"off\" expected."
             ;;
	  esac
          ;;
	si | siz | size )
	  if [[ -z $2 ]] ; then
	    _Dbg_msg "Argument required (integer to set it to.)."
	  elif [[ $2 != [0-9]* ]] ; then 
	      _Dbg_errmsg "Integer argument expected; got: $2"
	      return 1
	  fi
	  _Dbg_write_journal_eval "_Dbg_history_length=$2"
          ;;
        *)
	_Dbg_msg "\"save\", or \"size\" expected."
	;;
      esac
      ;;
    lin | line | linet | linetr | linetra | linetrac | linetrace )
      typeset onoff=${1:-'off'}
      case $onoff in 
	on | 1 ) 
	  _Dbg_write_journal_eval "_Dbg_linetrace=1"
	  ;;
	off | 0 )
	  _Dbg_write_journal_eval "_Dbg_linetrace=0"
	  ;;
	d | de | del | dela | delay )
	  if [[ $2 != [0-9]* ]] ; then 
	    _Dbg_msg "Bad int parameter: $2"
	    return 1
	  fi
	  eval "$_resteglob"
	  _Dbg_write_journal_eval "_Dbg_linetrace_delay=$2"
          ;;
	e | ex | exp | expa | expan | expand )
	  typeset onoff=${2:-'on'}
	  case $onoff in 
	    on | 1 ) 
	      _Dbg_write_journal_eval "_Dbg_linetrace_expand=1"
	      ;;
	    off | 0 )
	      _Dbg_write_journal_eval "_Dbg_linetrace_expand=0"
	      ;;
	    * )
	      _Dbg_msg "\"expand\", \"on\" or \"off\" expected."
             ;;
	  esac
	  ;;
	
	* )
	  _Dbg_msg "\"expand\", \"on\" or \"off\" expected."
	  return 1
      esac
      return 0
      ;;
    li | lis | list | lists | listsi | listsiz | listsize )
      if [[ $1 == [0-9]* ]] ; then 
	_Dbg_write_journal_eval "_Dbg_listsize=$1"
      else
	_Dbg_errmsg "Integer argument expected; got: $1"
	return 1
      fi
      return 0
      ;;
    lo | log | logg | loggi | loggin | logging )
      _Dbg_cmd_set_logging $*
      ;;
    p | pr | pro | prom | promp | prompt )
      _Dbg_prompt_str="$1"
      ;;
    sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
      case $1 in 
	1 )
	  _Dbg_write_journal_eval "_Dbg_show_command=on"
	  ;;
	0 )
	  _Dbg_write_journal_eval "_Dbg_show_command=off"
	  ;;
	on | off | auto )
	  _Dbg_write_journal_eval "_Dbg_show_command=$1"
	  ;;
	* )
	  _Dbg_msg "\"on\", \"off\" or \"auto\" expected."
      esac
      return 0
      ;;
    t|tr|tra|trac|trace|trace-|trace-c|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
      case $1 in 
	1 )
	  _Dbg_write_journal_eval "_Dbg_trace_commands=on"
	  ;;
	0 )
	  _Dbg_write_journal_eval "_Dbg_trace_commands=off"
	  ;;
	on | off )
	  _Dbg_write_journal_eval "_Dbg_trace_commands=$1"
	  ;;
	* )
	  _Dbg_msg "\"on\", \"off\" expected."
      esac
      return 0
      ;;
    w | wi | wid | width )
      if [[ $1 == [0-9]* ]] ; then 
	_Dbg_write_journal_eval "_Dbg_linewidth=$1"
      else
	_Dbg_msg "Integer argument expected; got: $1"
	return 1
      fi
      return 0
      ;;
    *)
      _Dbg_undefined_cmd "set" "$set_cmd"
      return 1
  esac
}
