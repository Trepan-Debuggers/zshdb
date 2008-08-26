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

function _Dbg_run_cmdline {
  typeset -a cmd
  cmd=( $(COLUMNS=3000 ps h -o command -p $$) )
  SH_RUN_CMDLINE=${cmd[@]}
}

_Dbg_not_running ()  {
  if (( ! _Dbg_running )) ; then 
    _Dbg_errmsg 'The program is not being run.'
    return 0
  fi
  return 1
}
