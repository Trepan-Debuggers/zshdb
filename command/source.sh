# -*- shell-script -*-
# gdb-like "source" command.
#
#   Copyright (C) 2002-2004, 2006, 2008, 2010, 2016
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
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

# Handle command-file source. If the filename's okay we just increase the
# input-file descriptor by one and redirect input which will
# be picked up in next debugger command loop.

_Dbg_help_add source \
'**source** *file*

Run debugger commands in *file*.'

_Dbg_do_source() {
    if (( $# == 0 )) ; then
        _Dbg_errmsg 'Need to give a filename for the "source" command.'
        return 1
    fi

    typeset filename
    _Dbg_tilde_expand_filename "$1"
    if [[ -r $filename ]] || [[ "$filename" == '/dev/stdin' ]] ; then
        # Redirect std input to new file and save new descriptor number
        exec {_Dbg_fdi}< $filename
        # Save descriptor number and assocated file name.
        _Dbg_fd+=($_Dbg_fdi)
        _Dbg_cmdfile+=("$filename")
    else
        _Dbg_errmsg "Source file \"$filename\" is not readable."
        return 3
    fi
    return 0
}
