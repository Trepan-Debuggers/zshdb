# -*- shell-script -*-
# hist.sh - Shell Debugger history routines
#
#   Copyright (C) 2008, 2011, 2014 Rocky Bernstein rocky@gnu.org
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

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && _Dbg_libdir='..' || _Dbg_libdir=${dirname}/..
    # dbg-oppts sets defines _Dbg_history_size, _Dbg_histfile, and
    # _Dbg_history_save
    source $_Dbg_libdir/dbg-opts
fi

typeset -i _Dbg_hi_last_stop=-1
typeset -i _Dbg_set_history=1

_Dbg_history_read() {
    if ((_Dbg_history_save)) && [[ -r $_Dbg_histfile ]] ; then
	builtin fc -R $_Dbg_histfile
    fi
}

# Save history file
_Dbg_history_write() {
    if (( _Dbg_history_size > 0 && _Dbg_set_history)) ; then
	# The following "fc" command doesn't work and I, rocky, don't
	# have the patients to deal with arcane zsh-isms to want to
	# make it work.
	## fc -WI $_Dbg_histfile
	cat /dev/null >$_Dbg_histfile
	typeset line
	typeset -a buffer
	typeset -a history
	typeset saveIFS
	saveIFS=$IFS; IFS=$'\n'; history=($(builtin fc -l)); IFS=$saveIFS
	typeset -i last=${#history[@]}
	typeset -i start=0
	typeset -i i
	((_Dbg_history_size < last+1)) && ((start=last+1-_Dbg_history_size))
	for ((i=start; i<=last; i++)); do
	    buffer=(${history[i]})
	    buffer[0]=()
	    print -- "${buffer[@]}" >> $_Dbg_histfile;
	done
    fi
}
