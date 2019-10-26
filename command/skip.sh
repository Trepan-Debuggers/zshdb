# -*- shell-script -*-
# gdb-like "skip" (step over) commmand.
#
#   Copyright (C) 2019 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add skip \
"**skip**

Skip (don't run) the next command(s).

Note that skipping doesn't change the value of \$?. This has
consequences in some compound statements that test on \$?. For example
in:

   if grep foo bar.txt ; then
      echo not skipped
   fi

skipping the *if* statement will in effect skip running the *grep*
command. Since the return code is 0 when skipped, the *if* body is
entered. Similarly the same thing can  happen in a *while* statement
test.

See also:
---------

**next**, **step**, **continue*, and **finish**.
"

_Dbg_do_skip() {
    _Dbg_last_cmd='skip'
,    _Dbg_skip=1
    return $?
}
