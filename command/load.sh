# -*- shell-script -*-
# Debugger load SCRIPT command.
#
#   Copyright (C) 2002-2006, 2008, 2010-2011,
#   2018-2019 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add load \
'**load** *zsh-script*

Read in lines of a *zsh-script*.

See also:
---------
**info files**
'

_Dbg_do_load() {

    if (( $# != 1 )) ; then
	_Dbg_errmsg "Expecting one filename parameter, Got $#."
	return 1
    fi

    typeset filename="$1"
    local full_filename=$(_Dbg_resolve_expand_filename "$filename")
    if [ -n "$full_filename" ] && [ -r "$full_filename" ] ; then
	# Have we already loaded in this file?
	for file in ${_Dbg_filenames[@]} ; do
	    if [[ $file == $full_filename ]] ; then
		_Dbg_msg "File $full_filename already loaded."
		return 2
	    fi
	done

	_Dbg_readin "$full_filename"
	_Dbg_msg "File $full_filename loaded."
    else
	_Dbg_errmsg "Couldn't resolve or read $filename"
	return 3
    fi
    return 0
}
