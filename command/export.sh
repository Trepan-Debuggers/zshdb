# -*- shell-script -*-
#   Copyright (C) 2011 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add export \
'**export** *var1* [**var2** ...]

Marks **var1**, **var2***, to get reassigned with their current values after on
subshell exit. The values are set by the debugger only after it
notices that the current shell is left.

Nothing is done if you aren not in a subshell.
'

_Dbg_do_export() {

  if (( $# == 0 )) ; then
      _Dbg_errmsg "Expecting at least one variable name; got none."
      return 0
      # return 1
  fi

  if (( 0 == $ZSH_SUBSHELL )) ; then
      _Dbg_errmsg "You are not in a subshell, so no value(s) need saving."
      return 0
      # return 2
  fi

  typeset var_name
  for var_name in  $@ ; do
      _Dbg_defined $var_name
      if (( $? == 0 )) ; then
          typeset val
          typeset val_cmd="val=\${$var_name}"
          eval "$val_cmd"
          _Dbg_write_journal "${var_name}=${val}"
      else
          _Dbg_errmsg "name: $var_name is not known to be a variable."
      fi
  done
  return 0
}
