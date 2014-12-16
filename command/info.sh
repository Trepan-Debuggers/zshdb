# -*- shell-script -*-
# info.sh - gdb-like "info" debugger commands
#
#   Copyright (C) 2002-2006, 2008-2009, 2010-2011, 2014
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

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && _Dbg_libdir='..' || _Dbg_libdir=${dirname}/..
    for lib_file in help alias ; do source $_Dbg_libdir/lib/${lib_file}.sh; done
    typeset -A _Dbg_complete_level_1_data
fi

typeset -A _Dbg_debugger_info_commands
typeset -A _Dbg_command_help_info

_Dbg_help_add info ''  # Help routine is elsewhere

typeset -a _Dbg_info_subcmds
_Dbg_info_subcmds=( breakpoints display files line program source stack variables )

# Load in "info" subcommands
for _Dbg_file in ${_Dbg_libdir}/command/info_sub/*.sh ; do
    source $_Dbg_file
done
_Dbg_complete_level_1_data[info]=$(echo ${(kM)_Dbg_debugger_info_commands})

_Dbg_do_info() {
    _Dbg_do_info_internal "$@"
    return $?
}

_Dbg_do_info_internal() {
    typeset info_cmd="$1"
    typeset label=$2

    # Warranty is omitted below.
    typeset subcmds='breakpoints display files line source stack variables'

    if [[ -z $info_cmd ]] ; then
        typeset thing
        for thing in $subcmds ; do
            _Dbg_do_info $thing 1
        done
        return 0
    elif [[ -n ${_Dbg_debugger_info_commands[$info_cmd]} ]] ; then
        ${_Dbg_debugger_info_commands[$info_cmd]} $label "$@"
        return $?
    fi

    case $info_cmd in
	#         a | ar | arg | args )
	#               _Dbg_do_info_args 3
	#             return 0
	#             ;;
        #       h | ha | han | hand | handl | handle | \
        #           si | sig | sign | signa | signal | signals )
        #         _Dbg_info_signals
        #         return
        #     ;;

        st | sta | stac | stack )
            _Dbg_do_backtrace 1 $@
            return 0
            ;;

        #       te | ter | term | termi | termin | termina | terminal | tt | tty )
        #     _Dbg_msg "tty: $_Dbg_tty"
        #     return;
        #     ;;

        *)
            _Dbg_errmsg "Unknown info subcommand: $info_cmd"
            _Dbg_errmsg "Info subcommands are:"
            typeset -a list; list=(${subcmds[@]})
            _Dbg_list_columns '  ' _Dbg_errmsg
            return -1
    esac
}

_Dbg_alias_add i info
