# setshow.sh - Helper routines for help/set/show
#
#   Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
#
#   This is free software; you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2, or (at your option) any later
#   version.
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

# Sets variable _Dbg_$2 to value $1 and then runs _Dbg_do_show $2.
_Dbg_set_onoff() {
    typeset onoff=${1:-'off'}
    typeset -l cmdname=$2
    case $onoff in
	on | 1 )
	    _Dbg_write_journal_eval "_Dbg_set_${cmdname}=1"
	    ;;
	off | 0 )
	    _Dbg_write_journal_eval "_Dbg_set_${cmdname}=0"
	    ;;
	* )
	    _Dbg_msg "\"on\" or \"off\" expected."
	    return 1
    esac
    _Dbg_do_show_internal $cmdname
    return 0
}

_Dbg_show_onoff() {
    typeset cmd="$1"
    typeset msg="$2"
    typeset label="$3"
    [[ -n $label ]] && label="${cmd}: "
    typeset onoff='off'
    typeset -l value
    eval "value=\$_Dbg_set_${cmd}"
    (( value )) && onoff='on.'
    _Dbg_msg \
	"${label}$msg is" $onoff
    return 0

}

_Dbg_help_set_onoff() {
    typeset -l cmd="$1"
    typeset -l label="$2"
    typeset -l msg="$3"
    typeset -l variable_value
    eval_cmd="variable_value=\${_Dbg_set_$cmd}"
    eval $eval_cmd
    [[ -n $label ]] && label="set $cmd  -- "
    typeset onoff="off."
    (( variable_value != 0 )) && onoff='on.'
    _Dbg_msg \
	"${label}${msg} is" $onoff
    return 0
}

# _Dbg_msg() {
#     print $*
# }

# for i in 0 1 ; do
#     _Dbg_foo=$i
#     _Dbg_help_set_onoff "foo" "foo" "Set short xx"
#     typeset -l _Dbg_foo
# done
