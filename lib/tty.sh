# -*- shell-script -*-
# Things related to tty
#
#   Copyright (C) 2008, 2011 Rocky Bernstein <rocky@gnu.org>
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

#
# Return 0 if $1 is a tty and open it. Otherwise return
# 0. _Dbg_new_fdi will be set to the file descriptor of the open tty
# or set to -1 if none could be opened.
#
# We write the interface this way because intead of say a routine to
# test a name refers to a terminal, because it's easy to tell if a
# file descriptor is a tty but not so easy using just the name. And we
# want to avoid opening and closing file descriptors unnecessarily.
#
function _Dbg_open_if_tty {
    _Dbg_new_fd=-1
    (( $# != 1 )) && return 1
    [[ ! -w $1 ]] && return 1
    typeset -i r=1
    # Code modelled off of code from David Korn:
    {
	if exec ${_Dbg_new_fd} > $1 ; then
	    if [[ -t $_Dbg_new_fd  ]] ; then
		r=0
	    else
		# Can't specify <> below like we did on the open
		# above, but since there's one input/output file
		# descriptor, in zsh both input and output are closed.
		exec {_Dbg_new_fd}<&-
		_Dbg_new_fd=-1
	    fi
	fi
    } 2> /dev/null

    return $r
}

# Redirect input and output to tty $1
# Stéphane Chazelas also suggests considering
## clone $tty
function _Dbg_set_tty {
  if (( $# != 1 )) ; then
    _Dbg_errmsg "Need a single tty parameter; got $# args instead."
    return 1
  fi
  typeset -i _Dbg_new_fd
  if _Dbg_open_if_tty $1 ; then
      _Dbg_fdi=$_Dbg_new_fd
      _Dbg_fd[-1]=$_Dbg_fdi
  else
      _Dbg_errmsg "$1 is not reputed to be a tty."
  fi
}
