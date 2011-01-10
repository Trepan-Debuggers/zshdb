# -*- shell-script -*-
# examine.sh: Examine debugger command.
#
#   Copyright (C) 2008, 2010, 2011 
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

_Dbg_help_add 'examine' \
"examine EXPR -- Print value of an expression via \'typeset', \`let' and failing these, eval. 

Single variables and arithmetic expressions do not need leading $ for
their value is to be substituted. However if neither these, variables
need $ to have their value substituted."

function _Dbg_do_examine {
  typeset _Dbg_expr; _Dbg_expr=${@:-"$_Dbg_last_x_args"}
  typeset _Dbg_result
  if [[ -z $_Dbg_expr ]] then 
      _Dbg_msg "$_Dbg_expr"      
  elif _Dbg_defined $_Dbg_expr ; then
    _Dbg_result=$(typeset -p $_Dbg_expr)
    _Dbg_msg "$_Dbg_result"
  elif _Dbg_is_function "$_Dbg_expr" $_Dbg_set_debugging; then 
    _Dbg_result=$(typeset -f $_Dbg_expr)
    _Dbg_msg "$_Dbg_result"
  else 
    typeset -i _Dbg_rc
    . ${_Dbg_libdir}/lib/set-d-vars.sh
    eval let _Dbg_result=$_Dbg_expr 2>/dev/null; _Dbg_rc=$?
    _Dbg_set_debugger_internal
    if (( _Dbg_rc != 0 )) ; then
	_Dbg_do_print "$_Dbg_expr"
    else
	_Dbg_msg "$_Dbg_result"
    fi
  fi
  _Dbg_last_x_args="$_Dbg_x_args"
}

_Dbg_alias_add 'x' 'examine'
