# -*- shell-script -*-
# gdb-like "kill" debugger command
#
#   Copyright (C) 2002-2006, 2008-2011, 2016 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add kill \
"**kill** [*signal-number*]

Send this process a POSIX signal ('9' for 'SIGKILL' or 'kill -SIGKILL')

9 is a non-maskable interrupt that terminates the program. If program is threaded it may
be expedient to use this command to terminate the program.

However other signals, such as those that allow for the debugged to handle them can be
sent.

Giving a negative number is the same as using its positive value.

Examples:
---------

    kill                # non-interuptable, nonmaskable kill
    kill 9              # same as above
    kill -9             # same as above
    kill 15             # nicer, maskable TERM signal
    kill! 15            # same as above, but no confirmation

See also:
---------

**quit** for less a forceful termination command.
**run** is a way to restart the debugged program."

_Dbg_do_kill() {
    if (($# > 1)); then
        _Dbg_errmsg "Got $# parameters, but need 0 or 1."
        return 0
        # return 1
    fi
    typeset _Dbg_prompt_output=${_Dbg_tty:-/dev/null}
    typeset signal='-9'
    (($# == 1)) && signal="$1"

    if [[ ${signal[0,0]} != '-' ]] ; then
        _Dbg_errmsg "Kill signal ($signal) should start with a '-'"
        return 0
        # return 2
    fi

    typeset _Dbg_response
    _Dbg_confirm "Send kill signal ${signal} which may terminate the debugger? (y/N): " 'N'

    if [[ $_Dbg_response == [yY] ]] ; then
        case $signal in
            -9 | -SEGV )
                _Dbg_cleanup2
                ;;
        esac
        kill $signal $$
    else
        _Dbg_msg "Kill not done - not confirmed."
        return 0
        # return 3
    fi
    return 0
}
