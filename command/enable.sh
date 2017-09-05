# -*- shell-script -*-
# gdb-like "enable" debugger command
#
#   Copyright (C) 2008-2009, 2011, 2016-2017 Rocky Bernstein
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

_Dbg_help_add enable \
'**enable** *bpnum1* [*bpnum2* ...]

Enables breakpoints *bpnum1*, *bpnum2*... Breakpoints numbers are
given as a space-separated list of numbers.

With no subcommand, breakpoints are enabled until you command otherwise.
This is used to cancel the effect of the "disable" command.

See also:
---------

**disable** and **info break**.'

# Enable breakpoint(s)/watchpoint(s) by entry number(s).
_Dbg_do_enable() {
    _Dbg_enable_disable 1 'enabled' "$@"
    return 0
}
