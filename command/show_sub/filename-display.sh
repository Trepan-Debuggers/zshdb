# -*- shell-script -*-
# "show filename-display" debugger command
#
#   Copyright (C) 2014, 2019-2021 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && top_dir='../..' || top_dir=${dirname}/../..
    for lib_file in help alias ; do source "$top_dir/lib/${lib_file}.sh"; done
    typeset -A _Dbg_command_help_show
    typeset -A _Dbg_debugger_show_commands
fi

_Dbg_help_add_sub show "filename-display" \
'**show filename-display**

Show how filenames are displayed.

See also:
---------

**set filename-display**.' 1

_Dbg_do_show_filename_display() {
    if [[ -n $1 ]]; then
	label=$(_Dbg_printf_nocr "%-12s: " "filename-display")
	if (( _Dbg_set_basename == 0 )) ; then
            _Dbg_msg 'is absolute.'
	else
            _Dbg_msg 'is basename.'
	fi
    else
        _Dbg_msg_nocr 'Filenames are displayed as '
	if (( _Dbg_set_basename == 0 )) ; then
            _Dbg_msg 'absolute.'
	else
            _Dbg_msg 'basename.'
	fi
    fi
    return 0
}
