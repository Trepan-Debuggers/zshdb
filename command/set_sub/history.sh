# -*- shell-script -*-
# "set history" debugger command
#
#   Copyright (C) 2010, 2011 Rocky Bernstein rocky@gnu.org
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

_Dbg_help_add_sub set history \
'Record command history' 1

_Dbg_do_set_history() {
    case "$1" in
        sa | sav | save )
            typeset onoff=${2:-'on'}
            case $onoff in
                on | 1 )
                    _Dbg_write_journal_eval "_Dbg_history_save=1"
                    ;;
                      off | 0 )
                    _Dbg_write_journal_eval "_Dbg_history_save=0"
                    ;;
                * )
                    _Dbg_errmsg "\"on\" or \"off\" expected."
                    return 1
                    ;;
            esac
            ;;
        si | siz | size )
            if [[ -z $2 ]] ; then
                _Dbg_errmsg "Argument required (integer to set it to.)."
            elif [[ $2 != [0-9]* ]] ; then
                _Dbg_errmsg "Integer argument expected; got: $2"
                return 1
            fi
            _Dbg_write_journal_eval "_Dbg_history_length=$2"
            ;;
        *)
            _Dbg_errmsg "\"save\", or \"size\" expected."
            return 1
            ;;
    esac
    return 0
}
