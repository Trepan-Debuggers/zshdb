# -*- shell-script -*-
# help.sh - gdb-like "help" debugger command
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

_Dbg_help_add help \
'help	- Print list of commands.'

typeset -i _Dbg_help_cols=6
_Dbg_do_help() {
  if ((0==$#)) ; then
      _Dbg_msg "Type 'help <command-name>' for help on a specific command.\n"
      _Dbg_msg 'Available commands:'
      typeset -a commands
      unsetopt ksharrays
      commands=(${(ki)_Dbg_command_help})
      print -C $_Dbg_help_cols $commands
      setopt ksharrays
#       typeset columnized; columnize "$commands" 45
#       typeset -i i
#       for ((i=0; i<${#columnized[@]}; i++)) ; do 
# 	  _Dbg_msg "  ${columnized[i]}"
#       done
      _Dbg_msg ''
      _Dbg_msg 'Readline command line editing (emacs/vi mode) is available.'
      _Dbg_msg 'Type "help" followed by command name for full documentation.'
      return 0
   else
      typeset dbg_cmd="$1"
      if [[ -n ${_Dbg_command_help[$dbg_cmd]} ]] ; then
 	  print ${_Dbg_command_help[$dbg_cmd]}
      else
	  typeset expanded_alias; _Dbg_alias_expand $dbg_cmd
	  dbg_cmd="$expanded_alias"
	  if [[ -n ${_Dbg_command_help[$dbg_cmd]} ]] ; then
 	      _Dbg_msg "${_Dbg_command_help[$dbg_cmd]}"

	  else
	      case $dbg_cmd in 
	      sh | sho | show )
		_Dbg_help_show $2
                return ;;
	      se | set  )
	        _Dbg_help_set $2
                return ;;
	     * )
  	        _Dbg_errmsg "Undefined command: \"$dbg_cmd\".  Try \"help\"."
  	         return ;;
	     esac
	  fi
      fi
  fi
}

_Dbg_alias_add '?' help
_Dbg_alias_add 'h' help
