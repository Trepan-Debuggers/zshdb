# -*- shell-script -*-
# Debugger pwd command.
#
#   Copyright (C) 2002-2004, 2006, 2008, 2010, 2016 Rocky Bernstein
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

_Dbg_help_add pwd \
'**pwd**

Show working directory.'

_Dbg_do_pwd() {
    typeset _Dbg_cwd; _Dbg_cwd=$(pwd)
    (( _Dbg_set_basename )) && _Dbg_cwd=${_Dbg_cwd##*/}
    _Dbg_msg "Working directory ${_Dbg_cwd}."
}
