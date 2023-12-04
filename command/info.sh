# -*- shell-script -*-
# info.sh - gdb-like "info" debugger commands
#
#   Copyright (C) 2002-2006, 2008-2009, 2010-2011, 2014, 2020, 2023
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

# Load in "info" subcommands
for _Dbg_file in "${_Dbg_libdir}"/command/info_sub/*.sh ; do
    source "$_Dbg_file"
done
_Dbg_complete_level_1_data[info]=$(echo ${(kM)_Dbg_debugger_info_commands})

_Dbg_do_info() {
    _Dbg_do_info_internal "$@"
    return $?
}

_Dbg_do_info_internal() {
    if (($# > 0)) ; then
        typeset subcmd="$1"
        shift

        if [[ -n ${_Dbg_debugger_info_commands[$subcmd]} ]] ; then
            ${_Dbg_debugger_info_commands[$subcmd]} "$@"
            return $?
        else
            # Look for a unique abbreviation
            typeset -i count=0
            typeset list; list="${(k)_Dbg_debugger_info_commands[@]}"
            for try in $list ; do
                if [[ $try =~ ^$subcmd ]] ; then
                    subcmd=$try
                    ((count++))
                fi
            done
            ((found=(count==1)))
        fi
        if ((found)); then
            ${_Dbg_debugger_info_commands[$subcmd]} "$@"
            return $?
        fi

        _Dbg_errmsg "Unknown info subcommand: $subcmd"
        msg=_Dbg_errmsg
    else
        msg=_Dbg_msg
    fi

    typeset -a list
    list=(${(k)_Dbg_debugger_info_commands[@]})
    sort_list 0 ${#list[@]}-1
    typeset -i width; ((width=_Dbg_set_linewidth-5))
    typeset -a columnized=(); columnize $width
    typeset -i i
    $msg "Info subcommands are:"
    for ((i=0; i<${#columnized[@]}; i++)) ; do
        $msg "  ${columnized[i]}"
    done
}

_Dbg_alias_add i info
