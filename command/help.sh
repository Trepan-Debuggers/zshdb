# -*- shell-script -*-
# help.sh - gdb-like "help" debugger command
#
#   Copyright (C) 2008, 2010, 2013, 2014 Rocky Bernstein <rocky@gnu.org>
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
    [[ $dirname == $0 ]] && top_dir='..' || top_dir=${dirname}/..
    for file in help alias ; do source $top_dir/lib/${file}.sh; done
fi

_Dbg_help_command_complete() {
    unsetopt ksharrays
    echo "${(ki)_Dbg_debugger_commands[@]} ${(ki)_Dbg_aliases[@]} *"
    setopt ksharrays
}

_Dbg_help_add help \
'**help** [*command* [*subcommand* ..]]

If no arguments are given, print a list of command names.
With a command name give help for that command. For many commands
you can get further detailed help by listing the subcommand name.

Examples:
---------

  help
  help up
  help set
  help set args
'

_Dbg_complete_level_1_data[help]='-A_Dbg_help_command_complete'

typeset -i _Dbg_help_cols=8
_Dbg_do_help() {

    # Treat "help *" the same as help
    ((1 == $#)) && [[ "$1" == '*' ]] && shift
    if ((0 == $#)) ; then
        _Dbg_section 'Available commands:'
        typeset -a commands
        unsetopt ksharrays
        commands=(${(ki)_Dbg_command_help})
        typeset -a list
        list=(${commands[@]})
        setopt ksharrays
        _Dbg_list_columns
        _Dbg_msg ''
        _Dbg_msg 'Readline command line editing (emacs/vi mode) is available.'
        _Dbg_msg 'Type "help" followed by command name for full documentation.'
        return 0
    else
        typeset dbg_cmd="$1"
        if [[ -n ${_Dbg_command_help[$dbg_cmd]} ]] ; then
	    _Dbg_msg_rst "${_Dbg_command_help[$dbg_cmd]}"
        else
            typeset expanded_alias; _Dbg_alias_expand $dbg_cmd
            dbg_cmd="$expanded_alias"
            if [[ -n ${_Dbg_command_help[$dbg_cmd]} ]] ; then
		_Dbg_msg_rst "${_Dbg_command_help[$dbg_cmd]}"
            else
                case $dbg_cmd in
                    i | in | inf | info )
                        _Dbg_help_info $2
			return 0
                        ;;
                    sh | sho | show )
                        _Dbg_help_show $2
			return 0
                        ;;
                    se | set )
                        _Dbg_help_set $2
			return 0
                        ;;
                    * )
                        _Dbg_errmsg "Undefined command: \"$dbg_cmd\".  Try \"help\"."
                        return 0
			;;
                esac
            fi
        fi
        aliases_found=''
        _Dbg_alias_find_aliased "$dbg_cmd"
        if [[ -n $aliases_found ]] ; then
            _Dbg_msg ''
            _Dbg_msg "Aliases for $dbg_cmd: $aliases_found"
        fi
        return 0
    fi
}

_Dbg_alias_add '?' help
_Dbg_alias_add 'h' help
