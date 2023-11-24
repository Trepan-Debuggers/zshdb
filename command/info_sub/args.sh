# -*- shell-script -*-
# "info args" debugger command
#
#   Copyright (C) 2023 Rocky Bernstein
#   <rocky@gnu.org>
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

# Print info args. Like GDB's "info args"
# Unfortunately, Zsh doesn't have an equivalent for "BASH_ARGC" and "BASH_ARGV".
# It's only possible to provide the arguments for the top frame.

_Dbg_help_add_sub info args \
    "**info args**

Show argument variables of the current stack frame.

See also:
---------

**backtrace**." 1

_Dbg_do_info_args() {
    if (($# != 0)); then
        _Dbg_errmsg "Arguments are not supported"
        return 1
    fi

    # Print out parameter list.
    typeset -i arg_count=${#_Dbg_frame_argv[@]}
    if ((arg_count == 0)); then
        _Dbg_msg "Argument count is 0 for this call."
    else
        typeset -i i
        for ((i = 1; i <= arg_count; i++)); do
            _Dbg_printf "$%d = %s" $i "${_Dbg_frame_argv[$i - 1]}"
        done
    fi
    return 0
}
