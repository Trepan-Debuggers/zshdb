# -*- shell-script -*-
# "set style" debugger command
#
#   Copyright (C) 2016 Rocky Bernstein <rocky@gnu.org>
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

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && top_dir='../..' || top_dir=${dirname}/../..
    for lib_file in help alias ; do source $top_dir/lib/${lib_file}.sh; done
    typeset -A _Dbg_command_help_set
    typeset -A _Dbg_debugger_set_commands
fi

typeset -A _Dbg_complete_level_2_data

export _Dbg_pygments_styles=$(${_Dbg_libdir}/lib/term-highlight.py -L)

_Dbg_complete_level_2_data[set_style]=$_Dbg_pygments_styles

_Dbg_help_add_sub set style \
'
set style [pygments style]

Set the pygments style use in listings.

See also: set highlight, show style, show highlight.
' 1


export _Dbg_set_style=''

_Dbg_do_set_style() {
    if ( pygmentize --version || pygmentize -V ) 2>/dev/null 1>/dev/null ; then
	:
    else
	_Dbg_errmsg "Can't run pygmentize. Setting forced off"
	return 1
    fi
    style=${1:-'colorful'}
    if [[ "${_Dbg_pygments_styles#*$style}" != "$_Dbg_pygments_styles" ]] ; then
	_Dbg_set_style=$style
	_Dbg_filecache_reset
	_Dbg_readin $_Dbg_frame_last_filename
	_Dbg_do_show style
    else
	_Dbg_errmsg "Can't find style $style"
    fi

    return 0
}
