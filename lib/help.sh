# -*- shell-script -*-
# help.sh - Debugger Help Routines
#   Copyright (C) 2008, 2010-2011, 2014, 2016 Rocky Bernstein <rocky@gnu.org>
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

# A place to put help command text
typeset -A _Dbg_command_help
export _Dbg_command_help

# List of debugger commands.
# FIXME: for now we are attaching this to _Dbg_help_add which
# is whe this is here. After moving somewhere more appropriate, relocate
# the definition.
typeset -A _Dbg_debugger_commands

# Add help text $2 for command $1
function _Dbg_help_add {
    add_command=${3:-1}
    (($# != 2)) && (($# != 3))  && return 1
    _Dbg_command_help[$1]="$2"
    (( add_command )) && _Dbg_debugger_commands[$1]="_Dbg_do_$1"
    return 0
}

# Add help text $3 for in subcommand $1 under key $2
function _Dbg_help_add_sub {
    (($# != 3)) && (($# != 4))  && return 1
    typeset -i add_command; add_command=${4:-1}
    eval "_Dbg_command_help_$1[$2]=\"$3\""
    if (( add_command )) ; then
        eval "_Dbg_debugger_$1_commands[$2]=\"_Dbg_do_${1}_${2}\""
    fi
    return 0
}

_Dbg_help_set() {

    typeset subcmd
    if (( $# == 0 )) ; then
        typeset -a list
        list=(${(ki)_Dbg_command_help_set[@]})
        sort_list 0 ${#list[@]}-1
        for subcmd in ${list[@]}; do
            _Dbg_help_set $subcmd 1
        done
        return 0
    fi

    subcmd="$1"
    typeset label="$2"

    if [[ -n "${_Dbg_command_help_set[$subcmd]}" ]] ; then
        if [[ -z $label ]] ; then
            _Dbg_msg_rst "${_Dbg_command_help_set[$subcmd]}"
            return 0
        else
            label=$(builtin printf "set %-12s-- " $subcmd)
        fi
    fi

    # FIXME: DRY this
    case $subcmd in
        an | ann | anno | annot | annota | annotat | annotate )
            [[ -n $label ]] && label='set annotate  -- '
            _Dbg_msg "${label}annotate style is ${_Dbg_set_annotate}"
            ;;
        ar | arg | args )
            [[ -n $label ]] && label='set args      -- '
            _Dbg_msg \
                "${label}Set argument list to give program when it is restarted."
            ;;
        autoeval  )
            [[ -n $label ]] && label='set autoeval  -- '
            _Dbg_msg \
                "${label}auto evaluation of unrecognized commands is" $(_Dbg_onoff $_Dbg_set_autoeval)
            ;;
        autolist  )
            [[ -n $label ]] && label='set autolist  -- '
	    typeset onoff="on."
	    [[ -z ${_Dbg_cmdloop_hooks["list"]} ]] && onoff='off.'
            _Dbg_msg \
                "${label}auto listing on debugger stop is ${onoff}"
            ;;
        b | ba | bas | base | basen | basena | basenam | basename )
            [[ -n $label ]] && label='set basename  -- '
            _Dbg_msg \
                "${label}basenames in files is" $(_Dbg_onoff $_Dbg_set_basename)
            ;;
        de|deb|debu|debug )
            [[ -n $label ]] && label='set debug     -- '
            _Dbg_msg \
                "${label}debug the debugger is" $(_Dbg_onoff $_Dbg_set_debug)
            ;;
        di|dif|diff|diffe|differe|differen|different )
            [[ -n $label ]] && label='set different -- '
            _Dbg_msg \
                "${label}stop on different lines is" $(_Dbg_onoff $_Dbg_set_different)
            ;;
        e | ed | edi | edit | editi | editin | editing )
            [[ -n $label ]] && label='set editing   -- '
            _Dbg_msg_nocr "${label}edit mode is "
	    if [[ -z $_Dbg_edit ]] ; then
		_Dbg_msg 'off.'
	    else
		_Dbg_msg 'on.'
	    fi
            ;;
        high | highl | highlight )
            [[ -n $label ]] && label='set highlight -- '
            _Dbg_msg_nocr \
                "${label}highlight style "
            if [[ -z $_Dbg_set_highlight ]] ; then
                _Dbg_msg 'off.'
            else
		_Dbg_msg "${_Dbg_set_highlight}"
            fi
            ;;
        his | hist | history )
            [[ -n $label ]] && label='set history   -- '
            _Dbg_msg_nocr \
                "${label}Set record command history is "
            if [[ -z $_Dbg_set_edit ]] ; then
                _Dbg_msg 'off.'
            else
                _Dbg_msg 'on.'
            fi
            ;;
        inferior-tty )
            [[ -n $label ]] && label='set inferior-tty -- '
            _Dbg_msg "${label} set tty for input and output"
            ;;
        lin | line | linet | linetr | linetra | linetrac | linetrace )
            [[ -n $label ]] && label='set linetrace -- '
            typeset onoff='off.'
            (( _Dbg_set_linetrace )) && onoff='on.'
            _Dbg_msg \
                "${label}Set tracing execution of lines before executed is" $onoff
            if (( _Dbg_set_linetrace )) ; then
                _Dbg_msg \
                    "set linetrace delay -- delay before executing a line is" $_Dbg_linetrace_delay
            fi
            return 0
            ;;
        lis | list | lists | listsi | listsiz | listsize )
            [[ -n $label ]] && label='set list size -- '
            _Dbg_msg "${label}Set number of lines in listings is ${_Dbg_set_listsize}"
	    ;;
        p | pr | pro | prom | promp | prompt )
            [[ -n $label ]] && label='set prompt    -- '
            _Dbg_msg "${label}prompt string ${_Dbg_set_prompt}"
            ;;
        sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
            [[ -n $label ]] && label='set showcommand -- '
            _Dbg_msg \
                "${label}command tracing is $_Dbg_set_show_command"
            ;;
        sty | style )
            [[ -n $label ]] && label='set style    -- '
            _Dbg_msg_nocr \
                "${label}Set pygments highlighting style is "
            if [[ -z $_Dbg_set_style ]] ; then
                _Dbg_msg 'off.'
            else
		_Dbg_msg "${_Dbg_set_style}"
            fi
            ;;
        wi|wid|widt|width )
            [[ -n $label ]] && label='set width    -- '
            _Dbg_msg "${label}Set line width is ${_Dbg_set_linewidth}"
            ;;
        * )
            _Dbg_msg \
                "There is no \"set $subcmd\" command."
    esac
}

typeset _Dbg_show_cmds="aliases annotate args autoeval autolist basename commands
copying directories debug force linetrace listsize prompt style trace-commands warranty"

_Dbg_help_show() {
    if (( $# == 0 )) ; then
        typeset -a list
        list=("${!_Dbg_command_help_show[@]}")
        sort_list 0 ${#list[@]}-1
        typeset subcmd
        for subcmd in ${list[@]}; do
            [[ $subcmd != 'version' ]] && _Dbg_help_show $subcmd 1
        done
        return 0
    fi

    typeset subcmd=$1
    typeset label="$2"

    if [[ -n "${_Dbg_command_help_show[$subcmd]}" ]] ; then
        if [[ -z $label ]] ; then
            _Dbg_msg_rst "${_Dbg_command_help_show[$subcmd]}"
            return 0
        else
            label=$(builtin printf "show %-12s-- " $subcmd)
        fi
    fi

    case $subcmd in
        ar | arg | args )
            _Dbg_msg \
                'show args        -- Show argument list to give program being debugged when it
                    is started.'
            return 0
            ;;
        an | ann | anno | annot | annota | annotat | annotate )
            _Dbg_msg \
                "show annotate    -- Show annotation_level"
            return 0
            ;;
        autoe | autoev | autoeva | autoeval )
            _Dbg_msg \
                'show autoeval    -- Show if we evaluate unrecognized commands.'
            return 0
            ;;
        autol | autoli | autolis | autolist )
            _Dbg_msg \
                "show autolist    -- Run list before command loop?"
            return 0
            ;;
        different | force)
            _Dbg_msg \
                'show different   -- Show if setting forces a different line.'
            ;;
        dir|dire|direc|direct|directo|director|directori|directorie|directories)
            _Dbg_msg \
                "show directories -- Show file directories searched for listing source."
            ;;
        lin | line | linet | linetr | linetra | linetrac | linetrace )
            _Dbg_msg \
                'show linetrace   -- Show whether to trace lines before execution.'
            ;;
        lis | list | lists | listsi | listsiz | listsize )
            _Dbg_msg \
                'show listsize    -- Show number of source lines debugger will list by default.'
            ;;
        p | pr | pro | prom | promp | prompt )
            _Dbg_msg \
                "show prompt      -- Show debugger's prompt."
            return 0
            ;;
        sty | style )
            _Dbg_msg \
                "show style       -- Show pygments style in source-code listings."
            ;;
        t|tr|tra|trac|trace|trace-|trace-c|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
            _Dbg_msg \
                'show trace-commands -- Show if we are echoing debugger commands'
            return 0
            ;;
        w | wa | war | warr | warra | warran | warrant | warranty )
            _Dbg_msg \
                'show warranty    -- Various kinds of warranty you do not have.'
            return 0
            ;;
        * )
            _Dbg_msg \
                "Undefined show command: \"$subcmd\".  Try \"help show\"."
    esac
}

_Dbg_help_info() {

    typeset subcmd
    if (( $# == 0 )) ; then
        typeset -a list
        list=(${(ki)_Dbg_command_help_info[@]})
        sort_list 0 ${#list[@]}-1
        for subcmd in ${list[@]}; do
            _Dbg_help_info $subcmd 1
        done
        return 0
    fi

    subcmd="$1"
    typeset label="$2"

    if [[ -n "${_Dbg_command_help_info[$subcmd]}" ]] ; then
        if [[ -z $label ]] ; then
            _Dbg_msg_rst "${_Dbg_command_help_info[$subcmd]}"
            return 0
        else
            label=$(builtin printf "info %-12s-- " $subcmd)
        fi
    fi

    _Dbg_info_help $subcmd $label
}
