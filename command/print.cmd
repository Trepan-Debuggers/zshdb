# -*- shell-script -*-
# Print command.
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

# The arguments in the last "print" command.
typeset _Dbg_last_print_args=''

add_help print \
'print *string*	Print value of a substituted string.'

_Dbg_do_print() {
  local -r _Dbg_expr=${@:-"$_Dbg_last_print_args"}
  local -r dq_expr=$(_Dbg_esc_dq "$_Dbg_expr")
  . ${_Dbg_libdir}/lib/set-d-vars.inc $_Dbg_debugged_exit_code
  eval "_Dbg_msg $_Dbg_expr"
  _Dbg_last_print_args="$dq_expr"
  _Dbg_set_debugger_internal
}
