# -*- shell-script -*-
# delete.sh - gdb-like "delete" debugger command
#
#   Copyright (C) 2002-2006, 2008, 2011, 2016-2017 Rocky Bernstein
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

_Dbg_help_add delete \
"**delete** {*brkpt-num*}...

Delete some breakpoints.

Arguments are breakpoint numbers with spaces in between. Without
arguments, clear all breaks (but first ask for confirmation).  "

# Routine to a delete breakpoint/watchpoint by entry numbers.
_Dbg_do_delete() {
    _Dbg_do_delete_internal $@
    return 0
}

_Dbg_do_delete_internal() {
  typeset to_go; to_go=$@
  typeset -i  i
  typeset -i  tot_found=0

  if (( $# == 0 )) ; then
      _Dbg_confirm "Delete all breakpoints? (y/N): " 'N'
      if [[ $_Dbg_response == [yY] ]] ; then
	  typeset to_go=$(_Dbg_breakpoint_list)
      else
	  return
      fi
  fi

  _Dbg_last_cmd='delete'
  for del in $to_go ; do
    case $del in
#       $_watch_pat )
#         _Dbg_delete_watch_entry ${del:0:${#del}-1}
#         ;;
      [0-9]* )
          if _Dbg_delete_brkpt_entry $del ; then
	      _Dbg_msg "Deleted breakpoint ${del}"
	      ((tot_found++))
	  fi
          ;;
      * )
        _Dbg_errmsg "Invalid entry number skipped: $del"
    esac
  done
  return $tot_found
}

_Dbg_alias_add 'd' delete

_Dbg_alias_add 'unset' 'delete'
