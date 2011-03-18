# -*- shell-script -*-
# "show alias" debugger command
#
#   Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add_sub show alias \
'show alias [NAME1 NAME2 ...]

If aliases names are given, show their definition. If left blank, show
all alias names' 1

_Dbg_do_show_alias() {
    unsetopt ksharrays
    typeset -a list
    list=()
    for alias in ${(ki)_Dbg_aliases} ; do
        list+=("${alias}: ${_Dbg_aliases[$alias]}")
    done
    setopt ksharrays
    _Dbg_list_columns '  |  '
    return 0
}
