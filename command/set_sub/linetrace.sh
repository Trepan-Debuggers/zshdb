# -*- shell-script -*-
# "set linetrace" debugger command
#
#   Copyright (C) 2010, 2014, 2016 Rocky Bernstein rocky@gnu.org
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
    [[ $dirname == $0 ]] && top_dir='../..' || top_dir=${dirname}/../..
    for lib_file in help alias ; do source $top_dir/lib/${lib_file}.sh; done
    typeset -A _Dbg_command_help_set
    typeset -A _Dbg_debugger_set_commands
fi

typeset -A _Dbg_complete_level_2_data
_Dbg_complete_level_2_data[set_linetrace]='on off delay expand'

_Dbg_help_add_sub set linetrace \
'**set linetrace** [**on**|**off**]

Set xtrace-style line tracing

See also:
---------

**show linetrace**
'

_Dbg_do_set_linetrace() {
    typeset onoff=${1:-'off'}
    case $onoff in
        on | 1 )
            _Dbg_write_journal_eval "_Dbg_set_linetrace=1"
            ;;
        off | 0 )
            _Dbg_write_journal_eval "_Dbg_set_linetrace=0"
            ;;
        d | de | del | dela | delay )
            if [[ $2 != [0-9]* ]] ; then
                _Dbg_errmsg "Bad integer parameter: $2"
                return 1
            fi
            eval "$_resteglob"
            _Dbg_write_journal_eval "_Dbg_linetrace_delay=$2"
            ;;
        e | ex | exp | expa | expan | expand )
            typeset onoff=${2:-'on'}
            case $onoff in
                on | 1 )
                    _Dbg_write_journal_eval "_Dbg_linetrace_expand=1"
                    ;;
                off | 0 )
                    _Dbg_write_journal_eval "_Dbg_linetrace_expand=0"
                    ;;
                * )
                    _Dbg_errmsg "\"expand\", \"on\" or \"off\" expected."
                    return 1
                    ;;
            esac
            ;;

        * )
            _Dbg_msg "\"expand\", \"on\" or \"off\" expected."
            return 1
    esac
    return 0
}
