# -*- shell-script -*-
# "set autoeval" debugger command
#
#   Copyright (C) 2011, 2014, 2016-2017 Rocky Bernstein <rocky@gnu.org>
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
_Dbg_complete_level_2_data[set_autoeval]='on off'

_Dbg_help_add_sub set autoeval \
'**set autoeval** [**on**|**off**]

Evaluate unrecognized debugger commands.

Often inside the debugger, one would like to be able to run arbitrary
Python commands without having to preface Python expressions with
``print`` or ``eval``. Setting *autoeval* on will cause unrecognized
debugger commands to be *eval* as a Python expression.

Note that if this is set, on error the message shown on type a bad
debugger command changes from:

      Undefined command: "fdafds". Try "help".

to something more zsh-eval-specific such as:

      /tmp/zshdb_eval_26397:2: command not found: fdafds


See also:
---------

**show autoeval**
'


_Dbg_do_set_autoeval() {
    _Dbg_set_onoff "$1" 'autoeval'
    return $?
}
