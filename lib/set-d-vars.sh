# -*- shell-script -*-
#$Id: set-d-vars.sh,v 1.2 2007/02/11 23:06:41 rockyb Exp $
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

# set dollar variables ($1, $2, ... $?) 
# to their values in the debugged environment before we entered the debugger.

typeset _Dbg_set_str='set --'
typeset -i _Dbg__i
for (( _Dbg__i=0 ; _Dbg__i<${#_Dbg_arg[@]}; _Dbg__i++ )) ; do
  local dq_argi="${_Dbg_arg[_Dbg__i]}"
  _Dbg_set_str="$_Dbg_set_str \"$dq_argi\""
done
eval $_Dbg_set_str

_Dbg_restore_user_vars

# Setting $? has to be done last.
_Dbg_set_dol_q $_Dbg_debugged_exit_code
