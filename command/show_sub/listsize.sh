# -*- shell-script -*-
# "show listsize" debugger command
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

_Dbg_help_add_sub show listsize \
'**show listsize**

Show maximum number of lines in a \"list\" display.

See also:
---------

**set listsize**.' 1

_Dbg_do_show_listsize() {
    [[ -n $label ]] && label=$(_Dbg_printf_nocr "%-12s: " listsize)
    _Dbg_msg \
	"${label}Number of source lines ${_Dbg_debugger_name} will list by default is" \
	"$_Dbg_set_listsize."
    return 0
}
