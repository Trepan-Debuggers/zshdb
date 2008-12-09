# -*- shell-script -*-
# Things related to tty
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

# Directory search patch for unqualified file names

#
# Return 1 if $1 is a tty else 0.
#
function _Dbg_is_tty {
    (( $# != 1 )) && return 1
    [[ -r "$1" && -w "$1" ]] && return 0
    return 1
}

# Redirect input and output to tty. 
function _Dbg_set_tty {
  if (( $# != 1 )) ; then
    _Dbg_errmsg "Need a single tty parameter got $# args instead"
    return 1
  fi
  typeset tty=$1
  if _Dbg_is_tty $1 ; then
      # exec {_Dbg_fdi} < $tty
      exec {_Dbg_fdi} > $tty
      _Dbg_fd[-1]=$_Dbg_fdi
  else
    _Dbg_errmsg "$1 is not reputed to be a tty."
  fi
}
