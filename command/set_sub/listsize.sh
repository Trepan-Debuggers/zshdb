# -*- shell-script -*-
# "set listsize" debugger command
#
#   Copyright (C) 2010-2011, 2014 Rocky Bernstein <rocky@gnu.org>
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


_Dbg_help_add_sub set listsize \
'**set listsize** *number-of-lines*

Set the number of source lines debugger will list by default.

See also:
---------

**show listsize**
'

_Dbg_do_set_listsize() {
    if [[ $1 == [0-9]* ]] ; then
        _Dbg_write_journal_eval "_Dbg_set_listsize=$1"
    else
        _Dbg_errmsg "Integer argument expected; got: $1"
        return -1
    fi
    return 0
}
