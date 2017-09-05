# -*- shell-script -*-
# gdb-like "info breakpoints" debugger command
#
#   Copyright (C) 2010, 2013-2017 Rocky Bernstein <rocky@gnu.org>
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

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && top_dir='../..' || top_dir=${dirname}/../..
    for lib_file in help alias ; do source $top_dir/lib/${lib_file}.sh; done
    typeset -A _Dbg_command_help_info
    typeset -A _Dbg_debugger_info_commands
fi

_Dbg_help_add_sub info breakpoints \
"**info breakpoints**

Show status of user-settable breakpoints. If no breakpoint numbers are
given, the show all breakpoints. Otherwise only those breakpoints
listed are shown and the order given.

The \"Disp\" column contains one of \"keep\", \"del\", the disposition of
the breakpoint after it gets hit.

The \"enb\" column indicates whether the breakpoint is enabled.

The \"Where\" column indicates where the breakpoint is located.
Info whether use short filenames

See also:
---------

**break**, **enable**, and **disable**." 1

_Dbg_info_breakpoints_complete() {
    _Dbg_breakpoint_list
}

typeset -A _Dbg_complete_level_2_data
_Dbg_complete_level_2_data[info_breakpoints]='-a_Dbg_info_breakpoints_complete'

# list breakpoints and break condition.
# If $1 is given just list those associated for that line.

_Dbg_do_info_breakpoints() {

    if (( $# >= 3  )) ; then
	typeset brkpt_num=$3
	if [[ $brkpt_num != [0-9]* ]] ; then
            _Dbg_errmsg "Bad breakpoint number $brkpt_num."
	elif [[ -z ${_Dbg_brkpt_file[$brkpt_num]} ]] ; then
            _Dbg_errmsg "Breakpoint entry $brkpt_num is not set."
	else
            typeset -r -i i=$brkpt_num
            typeset source_file=${_Dbg_brkpt_file[$i]}
            source_file=$(_Dbg_adjust_filename "$source_file")
            _Dbg_section "Num Type       Disp Enb What"
            _Dbg_printf "%-3d breakpoint %-4s %-3s %s:%s" $i \
		${_Dbg_keep[${_Dbg_brkpt_onetime[$i]}]} \
		${_Dbg_yn[${_Dbg_brkpt_enable[$i]}]} \
		"$source_file" ${_Dbg_brkpt_line[$i]}
            if [[ ${_Dbg_brkpt_cond[$i]} != '1' ]] ; then
		_Dbg_printf "\tstop only if %s" "${_Dbg_brkpt_cond[$i]}"
          fi
            _Dbg_print_brkpt_count $i
            return 0
	fi
	return 1
    fi

    if (( _Dbg_brkpt_count > 0 )); then
	typeset -i i

	_Dbg_section "Num Type       Disp Enb What"
	for (( i=1; i <= _Dbg_brkpt_max ; i++ )) ; do
            source_file="${_Dbg_brkpt_file[$i]}"
	    if [[ -n ${_Dbg_brkpt_line[$i]} ]] ; then
		source_file=$(_Dbg_adjust_filename "$source_file")
		_Dbg_printf "%-3d breakpoint %-4s %-3s %s:%d" $i \
		    ${_Dbg_keep[${_Dbg_brkpt_onetime[$i]}]} \
		    ${_Dbg_yn[${_Dbg_brkpt_enable[$i]}]} \
		    "$source_file" ${_Dbg_brkpt_line[$i]}
		if [[ ${_Dbg_brkpt_cond[$i]} != '1' ]] ; then
		    _Dbg_printf "\tstop only if %s" "${_Dbg_brkpt_cond[$i]}"
		fi
		_Dbg_print_brkpt_count $i
	    fi
	done
    else
	_Dbg_msg 'No breakpoints have been set.'
    fi
}
