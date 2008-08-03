# -*- shell-script -*-
# help.cmd - gdb-like "help" debugger command
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

typeset -i _Dbg_help_cols=6
# _Dbg_do_help() {
#   if ((0==$#)) ; then
#       print -C $_Dbg_help_cols $_Dbg_debugger_commands
#   elif ((1==$#)) ; then
#       if [[ -n ${_Dbg_command_help[(k)$1] ]] ; then
# 	  print ${_Dbg_command_help[(k)$1]}
#       else
# 	  print "Don't have help for $1"
#       fi
#   fi
# }
_Dbg_do_help() {
  if ((0==$#)) ; then
      print -C $_Dbg_help_cols $_Dbg_debugger_commands
   else
      local cmd=$1
      if [[ -n $_Dbg_command_help[(k)$cmd] ]] ; then
 	  print $_Dbg_command_help[$cmd]
      else
	  expand_alias $cmd
	  local cmd="$expanded_alias"
	  if [[ -n $_Dbg_command_help[(k)$cmd] ]] ; then
 	      print $_Dbg_command_help[$cmd]
	  else
      	      print "Don't have help for '$1'."
	  fi
      fi
  fi
}
