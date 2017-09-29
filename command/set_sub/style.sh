# -*- shell-script -*-
# "set style" debugger command
#
#   Copyright (C) 2016-2017 Rocky Bernstein <rocky@gnu.org>
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

typeset -x _Dbg_pygments_styles=''

if (( _Dbg_working_term_highlight )) ; then
   _Dbg_pygments_styles=$(${_Dbg_libdir}/lib/term-highlight.py -L)
fi

typeset -A _Dbg_complete_level_2_data
_Dbg_complete_level_2_data[set_style]="$_Dbg_pygments_styles off"

_Dbg_help_add_sub set style \
'
**set** **style** [*pygments-style* | **off**]

Set the pygments style use in souce-code listings to *pygments-style* or
remove any pygments formatting if *pygments-style* is **off**.

See also:
---------

See also: **set highlight**, **show style**, and **show highlight**.
'


_Dbg_list_styles() {
    typeset -a list=( $_Dbg_pygments_styles )
    _Dbg_msg "Valid styles are:"
    _Dbg_list_columns '  ' _Dbg_msg
}


_Dbg_do_set_style() {
    if (( ! _Dbg_working_term_highlight )) ; then
	_Dbg_errmsg "Can't run term-highlight. Setting forced off"
	return 1
    fi
    if (( $# == 0 )) ; then
	_Dbg_list_styles
    else
	style=$1
	if [[ "${style}" == "off" ]] ; then
	    _Dbg_set_style=''
	    _Dbg_filecache_reset
	    _Dbg_readin $_Dbg_frame_last_filename
	    _Dbg_do_show style
	elif [[ "${_Dbg_pygments_styles#*$style}" != "$_Dbg_pygments_styles" ]] ; then
	    _Dbg_set_style=$style
	    _Dbg_filecache_reset
	    _Dbg_readin $_Dbg_frame_last_filename
	    _Dbg_do_show style
	else
	    _Dbg_errmsg "Can't find style $style"
            _Dbg_list_styles
	fi
    fi

    return 0
}
