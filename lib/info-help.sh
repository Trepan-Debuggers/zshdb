# -*- shell-script -*-
# info.sh - Debugger "info" support

#   Copyright (C) 2008, 2016, 2019 Rocky Bernstein rocky@gnu.org
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

typeset -r _Dbg_info_cmds='breakpoints display files functions line program source stack variables warranty'

_Dbg_info_help() {

    if (( $# == 0 )) ; then
        typeset -a list
	_Dbg_section 'List of info subcommands:'

	for thing in $_Dbg_info_cmds ; do
	    _Dbg_info_help $thing 1
	done
        return 0
    fi


    typeset info_cmd=$1
    typeset label=$2

    if [[ -n "${_Dbg_command_help_info[$info_cmd]}" ]] ; then
	if [[ -z $label ]] ; then
            _Dbg_msg_rst "${_Dbg_command_help_info[$info_cmd]}"
            return 0
	else
            label=$(builtin printf "info %-12s-- " $info_cmd)
	fi
    fi

    if (($# > 0)) ; then
	typeset info_cmd=$1
	shift
	case $info_cmd in
# 	    ar | arg | args )
# 	        _Dbg_msg \
# 		    "info args -- Argument variables (e.g. \$1, \$2, ...) of the current stack frame."
# 	        return 0
# 	        ;;
	    b | br | bre | brea | 'break' | breakp | breakpo | breakpoints )
		_Dbg_msg \
		    'info breakpoints -- Status of user-settable breakpoints'
		return 0
		;;
 	    disp | displ | displa | display )
 	        _Dbg_msg \
 		    'info display -- Show all display expressions'
 	        return 0
 	        ;;
	    'fi' | fil | file | files | sources )
		_Dbg_msg \
		    'info files -- Source files in the program'
		return 0
		;;
	    'fu' | fun | func | funct | functi | functio | 'function' | functions )
		_Dbg_msg \
		    'info functions -- Functions defined in the program'
		return 0
		;;
	    l | li| lin | line )
		_Dbg_msg \
		    'info line -- List current line number and and file name'
		return 0
		;;
	    p | pr | pro | prog | progr | progra | program )
		_Dbg_msg \
		    'info program -- Execution status of the program.'
		return 0
		;;
# 	    h | ha | han | hand | handl | handle | \
# 	        si | sig | sign | signa | signal | signals )
# 	        _Dbg_msg \
# 		    'info signals -- What debugger does when program gets various signals'
# 	        return 0
# 	        ;;
	    so | sou | sourc | source )
		_Dbg_msg \
		    'info source -- Information about the current source file'
		return 0
		;;
	    st | sta | stac | stack )
		_Dbg_msg \
		    'info stack -- Backtrace of the stack'
		return 0
		;;
# 	    te | ter | term | termi | termin | termina | terminal | tt | tty )
# 	        _Dbg_msg \
# 		    'info terminal -- Print terminal device'
# 	        return 0
# 	        ;;
# 	    tr|tra|trac|trace|tracep | tracepo | tracepoi | tracepoint | tracepoints )
# 	        _Dbg_msg \
# 		    'info tracepoints -- Status of tracepoints'
# 	        return 0
# 	        ;;
	    v | va | var | vari | varia | variab | variabl | variable | variables )
		_Dbg_msg \
'info variables -- All global and static variable names'
		return 0
		;;
	    w | wa | war | warr | warra | warran | warrant | warranty )
		_Dbg_msg \
		    'info warranty -- Various kinds of warranty you do not have'
		return 0
		;;
	    * )
		_Dbg_errmsg "Unknown info subcommand: $info_cmd"
		msg=_Dbg_errmsg
	esac
    else
	msg=_Dbg_msg
    fi
    $msg "Info subcommands are:"
    typeset -a list; list=(${_Dbg_info_cmds})
    _Dbg_list_columns '  ' $msg
    [[ $msg == '_Dbg_errmsg' ]] && return 1 || return 0
}
