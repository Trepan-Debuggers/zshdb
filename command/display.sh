# -*- shell-script -*-
# display.sh - gdb-like "(un)display" and list display debugger commands
#
#   Copyright (C) 2002-2003, 200-2011, 2016
#   Rocky Bernstein <rocky@gnu.org>
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
#   along with this Program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

_Dbg_help_add display \
"**display** [*stmt*]

Evalute *stmt* each time the debugger is stopped. If *stmt* is omitted, evaluate
all of the display statements that are active. In contrast, **info display**
shows the display statements without evaluating them.

Examples:
---------

  display echo \$x  # show the current value of x each time debugger stops
  display          # evaluate all display statements

See also:
---------

**undisplay** and **info display**."

# Set display command or list all current display expressions
_Dbg_do_display() {
  if (( 0 == $# )); then
    _Dbg_eval_all_display
  else
    typeset -i n=_Dbg_disp_max++
    _Dbg_disp_exp[$n]="$@"
    _Dbg_disp_enable[$n]=1
    _Dbg_printf '%2d: %s' $n "${_Dbg_disp_exp[$n]}"
  fi
  return 0
}
