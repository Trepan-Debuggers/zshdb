# -*- shell-script -*-
# alias.sh - gdb-like "alias" debugger command
#
#   Copyright (C) 2008, 2010 Rocky Bernstein rocky@gnu.org
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

_Dbg_help_add alias \
'alias NAME DEBUGGER-COMMAND -- Make NAME be an alias for DEBUGGER-COMMAND.

Use "unalias" to remove an alias and "show aliases" to get a list the
aliases in effect.'

_Dbg_do_alias() {
  if (($# != 2)) ; then
      _Dbg_errmsg "Got $# parameter(s), but need 2."
      return 1
  fi
  _Dbg_alias_add $1 $2
  return 0
}

_Dbg_help_add unalias \
'unalias NAME -- Remove debugger command alias NAME.

Use "show aliases" to get a list the aliases in effect.'

_Dbg_do_unalias() {
  if (($# != 1)) ; then
      _Dbg_errmsg "Got $# parameters, but need 1."
  fi
  _Dbg_alias_remove $1
}
