# -*- shell-script -*-
# set.sh - debugger settings
#
#   Copyright (C) 2008, 2010-2011, 2014 Rocky Bernstein <rocky@gnu.org>
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
#   You should have received a copy of the GNU General Public License along
#   with this program; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.

# Sets whether or not to display command to be executed in debugger prompt.
# If yes, always show. If auto, show only if the same line is to be run
# but the command is different.

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && _Dbg_libdir='..' || _Dbg_libdir=${dirname}/..
    for lib_file in help alias ; do source $_Dbg_libdir/lib/${lib_file}.sh; done
    typeset -A _Dbg_complete_level_1_data
fi

typeset -A _Dbg_debugger_info_commands
typeset -i _Dbg_set_linewidth; _Dbg_set_linewidth=${COLUMNS:-80}
typeset -i _Dbg_linetrace_expand=0 # expand variables in linetrace output
typeset    _Dbg_linetrace_delay=1  # sleep after linetrace

typeset -A _Dbg_debugger_set_commands
typeset -A _Dbg_command_help_set

typeset -i _Dbg_set_autoeval=0     # Evaluate unrecognized commands?
typeset -i _Dbg_set_listsize=10    # How many lines in a listing?

_Dbg_help_add set ''  # Help routine is elsewhere

# Load in "set" subcommands
for _Dbg_file in ${_Dbg_libdir}/command/set_sub/*.sh ; do
    source "$_Dbg_file"
done
_Dbg_complete_level_1_data[set]=$(echo ${(kM)_Dbg_debugger_set_commands})

_Dbg_do_set() {
    _Dbg_do_set_internal "$@"
    return $?
}

_Dbg_do_set_internal() {
    typeset set_cmd="$1"
    typeset rc
    if [[ $set_cmd == '' ]] ; then
	_Dbg_msg "Argument required (expression to compute)."
	return;
    fi
    _Dbg_last_cmd='set'
    shift

    if [[ -n ${_Dbg_debugger_set_commands[$set_cmd]} ]] ; then
	${_Dbg_debugger_set_commands[$set_cmd]} $label "$@"
	return $?
    fi

    case $set_cmd in
	force | dif | diff | differ | different )
            _Dbg_set_onoff "$1" 'different'
            ;;
	inferior-tty )
            _Dbg_set_tty "$@"
            ;;
	lo | log | logg | loggi | loggin | logging )
            _Dbg_cmd_set_logging $@
            ;;
	t|tr|tra|trac|trace|trace-|trace-c|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
            _Dbg_do_set_trace_commands $@
            ;;
	*)
            _Dbg_undefined_cmd "set" "$set_cmd"
            return -1
    esac
    return $?
}
