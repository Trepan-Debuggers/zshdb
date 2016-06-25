# -*- shell-script -*-
# "set args" debugger command
#
#   Copyright (C) 2010-2011, 2016 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add_sub set args \
'**set** *args** *script-args*

Set argument list to give program being debugged when it is started.
Follow this command with any number of args, to be passed to the program.'

_Dbg_do_set_args() {
    # We use the loop below rather than _Dbg_set_args="(@)" because
    # we want to preserve embedded blanks in the arguments.
    _Dbg_script_args=()
    typeset -i i
    typeset -i n=$#
    for (( i=0; i<n ; i++ )) ; do
        _Dbg_write_journal_eval "_Dbg_script_args[$i]=$1"
        shift
    done
    return 0
}
