# -*- shell-script -*-
# gdb-like "backtrace" debugger command
#
#   Copyright (C) 2008, 2016, 2018 Rocky Bernstein <rocky@gnu.org>
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

# This code assumes the version of zsh where functrace has file names
# and absolute line positions, not function names and offset.

_Dbg_help_add backtrace \
'**backtrace** [*opts*] [*count*]

Print backtrace of all stack frames, or innermost *count* frames.

With a negative argument, print outermost -*count* frames.

An arrow indicates the "current frame". The current frame determines
the context used for many debugger commands such as expression
evaluation or source-line listing.

*opts* are:

   -s | --source  - show source code line
   -h | --help    - give this help

Examples:
---------

   backtrace      # Print a full stack trace
   backtrace 2    # Print only the top two entries
   backtrace -1   # Print a stack trace except the initial (least recent) call.
   backtrace -s   # show source lines in listing
   backtrace --source   # same as above

See also:
---------

**frame** and  **list**
'

# Print a stack backtrace. $1 after processing options is the maximum
# number of entries to include.
_Dbg_do_backtrace() {

    _Dbg_not_running && return 1

    local -A shortopts
    typeset -i show_source=0
    emulate -L sh
    setopt kshglob noshglob braceexpand nokshautoload
    shortopts=(s source)

    while getopts "hs" name; do
	case $name in
	    [s]) OPTARG="${shortopts[$name]}" ;&
	    s)
		show_source=1
		shift
		;;
	    h)
		_Dbg_do_help backtrace
		return
		;;
	esac
    done

    typeset prefix='##'
    typeset -i at_most=${#_Dbg_frame_stack[@]}
    typeset -i count=${1:-$at_most}
    typeset -i i=0

    if (( count < 0 )) ; then
	(( i = at_most + count ))
	(( count = at_most ))
    fi

    # Loop which dumps out stack trace.
    for (( ; (( i < at_most && count > 0 )) ; i++ )) ; do
	_Dbg_print_frame $i $show_source
	((count--))
    done
    return 0
}

_Dbg_alias_add bt backtrace
_Dbg_alias_add T backtrace
_Dbg_alias_add where backtrace
