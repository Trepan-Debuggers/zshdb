# -*- shell-script -*-
# help.sh - Debugger Help Routines
#   Copyright (C) 2008, 2010, 2011 Rocky Bernstein <rocky@gnu.org>
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
            _Dbg_msg "${_Dbg_command_help_set[$subcmd]}"
            return 0
        else
            label=$(builtin printf "set %-12s-- " $subcmd)
        fi
    fi

    case $subcmd in
        ar | arg | args )
            [[ -n $label ]] && label='set args      -- '
            _Dbg_msg \
                "${label}Set argument list to give program when it is restarted.
Follow this command with any number of args, to be passed to the program."
            return 0
            ;;
        an | ann | anno | annot | annota | annotat | annotate )
            if [[ -n $label ]] ; then
                label='set annotate  -- '
            else
                typeset post_label='
0 == normal;     1 == fullname (for use when running under emacs).'
            fi
            _Dbg_msg \
                "${label}Set annotation level.$post_label"
            return 0
            ;;
        autoe | autoev | autoeva | autoeval )
            _Dbg_help_set_onoff 'autoeval' 'autoeval' \
                "Evaluate unrecognized commands"
            return 0
            ;;
        autol | autoli | autolis | autolist )
            [[ -n $label ]] && label='set autolist  -- '
            typeset -l onoff="on."
            [[ -z ${_Dbg_cmdloop_hooks['list']} ]] && onoff='off.'
            _Dbg_msg \
                "${label}Run list command is ${onoff}"
            return 0
            ;;
        b | ba | bas | base | basen | basena | basenam | basename )
            _Dbg_help_set_onoff 'basename' 'basename' \
                "Set short filenames (the basename) in debug output"
            return 0
            ;;
        deb|debu|debug )
            _Dbg_help_set_onoff 'debug' 'debug' \
                "Set debugging the debugger"
            return 0
            ;;
        force | dif | diff | differ | different )
            _Dbg_help_set_onoff 'different' 'different' \
                "Set stepping forces a different line"
            return 0
            ;;
        e | ed | edi | edit | editi | editin | editing )
            [[ -n $label ]] && label='set editing   -- '
            _Dbg_msg_nocr \
                "${label}Set editing of command lines as they are typed is "
            if [[ -z $_Dbg_edit ]] ; then
                _Dbg_msg 'off.'
            else
                _Dbg_msg 'on.'
            fi
            return 0
            ;;
        high | highl | highlight )
            [[ -n $label ]] && label='set highlight -- '
            _Dbg_msg_nocr \
                "${label}Set syntax highlighting of source listings is "
            if [[ -z $_Dbg_edit ]] ; then
                _Dbg_msg 'off.'
            else
                _Dbg_msg 'on.'
            fi
            return 0
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
        si | siz | size )
            eval "$_seteglob"
            if [[ -z $2 ]] ; then
                _Dbg_errmsg "Argument required (integer to set it to.)."
            elif [[ $2 != $int_pat ]] ; then
                _Dbg_errmsg "Integer argument expected; got: $2"
                eval "$_resteglob"
                return 1
            fi
            eval "$_resteglob"
            _Dbg_write_journal_eval "_Dbg_history_length=$2"
            return 0
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
            [[ -n $label ]] && label='set listsize  -- '
            _Dbg_msg \
                "${label}Set number of source lines $_Dbg_debugger_name will list by default."
            ;;
        p | pr | pro | prom | promp | prompt )
            [[ -n $label ]] && label='set prompt    -- '
            _Dbg_msg \
                "${label}${_Dbg_debugger_name}'s prompt is:\n" \
                "      \"$_Dbg_prompt_str\"."
            return 0
            ;;
        sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
            [[ -n $label ]] && label='set showcommand -- '
            _Dbg_msg \
                "${label}Set showing the command to execute is $_Dbg_show_command."
            return 0
            ;;
        t|tr|tra|trac|trace|trace-|tracec|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
            [[ -n $label ]] && label='set trace-commands -- '
            _Dbg_msg \
                "${label}Set showing debugger commands is $_Dbg_set_trace_commands."
            return 0
            ;;
	w|wi|wid|widt|width )
            [[ -n $label ]] && label='set width          -- '
            _Dbg_msg \
                "${label}Set line length to use in output."
            ;;
        * )
            _Dbg_msg \
                "There is no \"set $subcmd\" command."
    esac
}

typeset _Dbg_show_cmds="aliases annotate args autoeval autolist basename commands
copying directories debug force linetrace listsize prompt trace-commands warranty"

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
            _Dbg_msg "${_Dbg_command_help_show[$subcmd]}"
            return 0
        else
            label=$(builtin printf "show %-12s-- " $subcmd)
        fi
    fi

    case $subcmd in
        al | ali | alia | alias | aliase | aliases )
            _Dbg_msg \
                'show aliases     -- Show list of aliases currently in effect.'
            return 0
            ;;
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
        b | ba | bas | base | basen | basena | basenam | basename )
            _Dbg_msg \
                'show basename    -- Show if we are are to show short or long filenames.'
            return 0
            ;;
        com | comm | comma | comman | command | commands )
            _Dbg_msg \
                'show commands    -- Show the history of commands you typed.'
            ;;
        cop | copy| copyi | copyin | copying )
            _Dbg_msg \
                'show copying     -- Conditions for redistributing copies of debugger.'
            ;;
        d|de|deb|debu|debug )
            _Dbg_msg \
                'show debug       -- Show if we are set to debug the debugger.'
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
        editing )
            _Dbg_msg \
                "$label Show editing of command lines and edit style."
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
