# -*- shell-script -*-
# "info functions" debugger command
#
#   Copyright (C) 2020 Rocky Bernstein rocky@gnu.org
#
#   zshdb is free software; you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2, or (at your option) any later
#   version.
#
#   zshdb is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with zshdb; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.

_Dbg_help_add_sub info functions '
**info functions** [*string-pattern*]

List function names. If *string-pattern* is given, the results
are filtered using the shell "=" (or "==") test.

Examples:
---------

    info functions    # show all functions
    info functions co # show all functions with "co" in the name

' 1

_Dbg_do_info_functions() {
    # Remove "functions" or "xx functions"
    if [[ "$1" != "functions" ]] ; then
	shift
    fi
    if [[ "$1" == "functions" ]]; then
	shift
    fi
    _Dbg_do_list_typeset_attr '+f' $@
    return 0
}
