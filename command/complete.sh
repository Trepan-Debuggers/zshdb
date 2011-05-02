# complete.sh - gdb-like 'complete' command
#
#   Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add complete \
'complete PREFIX-STR...

Show command completion strings for PREFIX-STR
'

_Dbg_do_complete() {
  typeset -a _Dbg_commands; _Dbg_commands=( - 
	. / a break
	cd commands complete continue condition clear
	d debug delete disable display
	D deleteall down eval enable examine
	file finish frame 
	handle help history info
	list kill next step skip print pwd quit reverse
	search set show signal source toggle tbreak tty
	up undisplay watche version window 
	A x L M R S T We )

    typeset -a args; args=($@)
    _Dbg_matches=()
    if (( ${#args[@]} == 2 )) ; then
      _Dbg_subcmd_complete ${args[0]} ${args[1]}
    elif (( ${#args[@]} == 1 )) ; then 
	_Dbg_msg "complete command not completed yet."
	# FIXME: figure out zsh's equivalent for:
	# eval "builtin compgen -W \"${_Dbg_commands[@]}\" ${args[0]}"
	:
    fi  
    typeset -i i
    for (( i=0;  i < ${#_Dbg_matches[@]}  ; i++ )) ; do 
      _Dbg_msg ${_Dbg_matches[$i]}
    done
}

