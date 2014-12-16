# -*- shell-script -*-
# show.sh - Show debugger settings
#
#   Copyright (C) 2008, 2010-2011, 2014
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
#   along with This program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && _Dbg_libdir='..' || _Dbg_libdir=${dirname}/..
    for lib_file in help alias ; do source $_Dbg_libdir/lib/${lib_file}.sh; done
    typeset -A _Dbg_complete_level_1_data
fi

typeset -A _Dbg_debugger_show_commands
typeset -A _Dbg_command_help_show

# subcommands whose current values are not shown in a "show" list .
# These are things like alias, warranty, or copying.
# They are available if asked for explicitly, e.g. "show copying"
typeset -A _Dbg_show_nolist

_Dbg_help_add show ''  # Help routine is elsewhere

# Load in "show" subcommands
for _Dbg_file in ${_Dbg_libdir}/command/show_sub/*.sh ; do
    source $_Dbg_file
done
_Dbg_complete_level_1_data[show]=$(echo ${(kM)_Dbg_debugger_show_commands})

_Dbg_do_show() {
    _Dbg_do_show_internal $@
    return $?
}

_Dbg_do_show_internal() {
    typeset show_cmd=$1
    typeset label=$2

    # Warranty, copying, directories, and aliases are omitted below.
    typeset subcmds='annotate args autoeval autolist basename debug editing force history listsize prompt trace-commands width'

    if [[ -z $show_cmd ]] ; then
        typeset thing
        for thing in $subcmds ; do
            _Dbg_do_show $thing 1
        done
        return 0
    elif [[ -n ${_Dbg_debugger_show_commands[$show_cmd]} ]] ; then
	[[ -n ${_Dbg_show_nolist[$thing]} ]] || \
            ${_Dbg_debugger_show_commands[$show_cmd]} $label
        return $?
    fi

    case $show_cmd in
        ar | arg | args )
            [[ -n $label ]] && label='args:     '
            _Dbg_msg \
                "${label}Argument list to give script when debugged program starts is:\n" \
                "      \"${_Dbg_script_args[@]}\"."
            return 0
            ;;
        an | ann | anno | annot | annota | annotat | annotate )
            [[ -n $label ]] && label='annotate: '
            _Dbg_msg \
                "${label}Annotation_level is $_Dbg_set_annotate."
            return 0
            ;;
        autoe | autoev | autoeva | autoeval )
            [[ -n $label ]] && label='autoeval: '
            _Dbg_msg \
                "${label}Evaluate unrecognized commands is" $(_Dbg_onoff $_Dbg_set_autoeval)
            return 0
            ;;
        autol | autoli | autolis | autolist )
            [[ -n $label ]] && label='autolist: '
            typeset onoff="on."
            [[ -z ${_Dbg_cmdloop_hooks["list"]} ]] && onoff='off.'
            _Dbg_msg \
                "${label}Auto run of 'list' command is ${onoff}"
            return 0
            ;;
        b | ba | bas | base | basen | basena | basenam | basename )
            [[ -n $label ]] && label='basename: '
            _Dbg_msg \
                "${label}Show short filenames (the basename) in debug output is" $(_Dbg_onoff $_Dbg_set_basename)
            return 0
            ;;
        dir|dire|direc|direct|directo|director|directori|directorie|directories)
            typeset list=${_Dbg_dir[0]}
            typeset -i n=${#_Dbg_dir[@]}
            typeset -i i
            for (( i=1 ; i < n; i++ )) ; do
                list="${list}:${_Dbg_dir[i]}"
            done

            _Dbg_msg "Source directories searched: $list"
            return 0
            ;;
        force | diff | differ | different )
            [[ -n $label ]] && label='different: '
            _Dbg_msg \
                "${label}Show stepping forces a new line is" $(_Dbg_onoff $_Dbg_set_different)
            return 0
            ;;
        lin | line | linet | linetr | linetra | linetrac | linetrace )
            [[ -n $label ]] && label='line tracing: '
            typeset onoff="off."
            (( _Dbg_set_linetrace != 0 )) && onoff='on.'
            _Dbg_msg \
                "${label}Show line tracing is" $onoff
            _Dbg_msg \
                "${label}Show line trace delay is ${_Dbg_linetrace_delay}."
            return 0
            ;;

        lis | list | lists | listsi | listsiz | listsize )
            [[ -n $label ]] && label='listsize: '
            _Dbg_msg \
                "${label}Number of source lines ${_Dbg_debugger_name} will list by default is" \
                "$_Dbg_set_listsize."
            return 0
            ;;

        lo | log | logg | loggi | loggin | logging )
            shift
            _Dbg_do_show_logging $*
            ;;
        p | pr | pro | prom | promp | prompt )
            [[ -n $label ]] && label='prompt:   '
            _Dbg_msg \
                "${label}${_Dbg_debugger_name}'s prompt is:\n" \
                "      \"$_Dbg_prompt_str\"."
            return 0
            ;;
        sho|show|showc|showco|showcom|showcomm|showcomma|showcomman|showcommand )
            [[ -n $label ]] && label='showcommand: '
            _Dbg_msg \
                "${label}Show commands in debugger prompt is" \
                "$_Dbg_set_show_command."
            return 0
            ;;
        t|tr|tra|trac|trace|trace-|tracec|trace-co|trace-com|trace-comm|trace-comma|trace-comman|trace-command|trace-commands )
            [[ -n $label ]] && label='trace-commands: '
            _Dbg_msg \
                "${label}State of command tracing is" \
                "$_Dbg_set_trace_commands."
            return 0
            ;;
        v | ve | ver | vers | versi | versio | version )
            _Dbg_do_show_version
            return 0
            ;;
        wi | wid | width )
            [[ -n $label ]] && label='width: '
            _Dbg_msg \
                "${label}Line width is $_Dbg_set_linewidth."
            return 0
            ;;
        *)
            _Dbg_errmsg "Unknown show subcommand: $show_cmd"
            _Dbg_errmsg "Show subcommands are:"
            typeset -a list; list=(${subcmds[@]})
            _Dbg_list_columns '  ' _Dbg_errmsg
            return -1
    esac
}
