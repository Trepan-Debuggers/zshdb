# -*- shell-script -*-
# "set history" debugger command
#
#   Copyright (C) 2010-2011, 2014, 2016 Rocky Bernstein <rocky@gnu.org>
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
_Dbg_complete_level_2_data[set_history]='filename save size'

_Dbg_help_add_sub set history \
'**set history save** [**on**|**off**]

**set history size** *num*

**set history filename** *path*

In the first form, set whether to save history.
This only works if the debugger or zsh was started in interactive
mode, option --interactive or -i

In the second form, how many history lines to save is indicated.

In the third form, the place to store the history file is given.
'

_Dbg_do_set_history() {
    case "$1" in
        sa | sav | save )
            typeset onoff=${2:-'on'}
	    if [[ onoff == 'on' ]] && ! setopt | grep interactive 2>&1 >/dev/null; then
		_Dbg_errmsg "zsh was not started interactively, can't save history"
		_Dbg_set_history=0
		return -1
	    fi
	    _Dbg_set_onoff $onoff 'history'

            ;;
        si | siz | size )
            if [[ -z $2 ]] ; then
                _Dbg_errmsg "Argument required (integer to set it to.)."
            elif [[ $2 != [0-9]* ]] ; then
                _Dbg_errmsg "Integer argument expected; got: $2"
                return -1
            fi
            _Dbg_write_journal_eval "_Dbg_history_size=$2"
            ;;
        file | filename )
	    # TODO: check validity of filename
            _Dbg_write_journal_eval "_Dbg_histfile=$2"
	    ;;
        *)
            _Dbg_errmsg "\"filename\", \"save\", or \"size\" expected."
            return -1
            ;;
    esac
    return 0
}
