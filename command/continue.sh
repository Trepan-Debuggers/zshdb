# -*- shell-script -*-
# continue.sh - gdb-like "continue" debugger command
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


_Dbg_help_add continue \
'continue [LOC | - ] -- Continue script execution. 

If not LOC or - is given, continue until the next breakpoint or the end
of program is reached.  If - is given, then debugging will be turned off
after continuing causing your program to run at full speed. 

If LOC is given, a temporary breakpoint is set at the location.'

function _Dbg_do_continue {

  _Dbg_not_running && return 1

  [[ -z $1 ]] && return 0
  typeset filename
  typeset -i line_number
  typeset full_filename

  if [[ $1 == '-' ]] ; then
    _Dbg_restore_debug_trap=0
    return 0
  fi

  _Dbg_linespec_setup "$1"

  if [[ -n "$full_filename" ]] ; then 
    if (( line_number ==  0 )) ; then 
      _Dbg_errmsg 'There is no line 0 to continue at.'
    else 
      _Dbg_check_line $line_number "$full_filename"
      (( $? == 0 )) && \
	_Dbg_set_brkpt "$full_filename" "$line_number" 1 1
      return 0
    fi
  else
    _Dbg_file_not_read_in "$filename"
  fi
  return 1
}

_Dbg_alias_add 'c' 'continue'
_Dbg_alias_add 'cont' 'continue'
