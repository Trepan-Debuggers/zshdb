# -*- shell-script -*-
# complete.sh  - command completion handling
#
#   Copyright (C) 2006, 2011, 2014 Rocky Bernstein <rocky@gnu.org>
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

typeset -a _Dbg_matches; _Dbg_matches=()

# gdb style "complete" command completion.
# Print a list of completions in global variable _Dbg_matches
# for 'subcmd' that start with 'text'.
# We get the list of completions from _Dbg._*subcmd*_cmds.
# If no completion, we return the empty list.
_Dbg_subcmd_complete() {
    subcmd=$1
    text=$2
    _Dbg_matches=()
    typeset list=''
    cmd="list=\${(k)_Dbg_debugger_${subcmd}_commands[@]}"
    eval $cmd
    local -i last=0
    for word in $list ; do
        # See if $word contains $text at the beginning. We use the string
        # strip operatior '#' and check that some part of $word was stripped
        if [[ ${word#$text} != $word ]] ; then
            _Dbg_matches[$last]="$subcmd $word"
            ((last++))
        fi
    done
    # return _Dbg_matches
}

# Interactive completion. level_0 is top-level matching which for the
# the debugger are commands and aliases. The below routine also splits
# out subcommands and sub-sub commands and calls the appropriate
# completion routines
_Dbg_complete_level_0() {
    if ((1 == CURRENT)) ; then
	compadd -- ${(ki)_Dbg_debugger_commands[@]} ${(ki)_Dbg_aliases[@]}
    elif ((2 == CURRENT)) ; then
	_Dbg_complete_level_1 ${words[0]}
    elif ((3 == CURRENT)) ; then
	_Dbg_complete_level_2 "${words[0]}_${words[1]}"
    fi
}

# Interactive completion for level_1. This is completion for debugger
# command arguments like "frame", "help" and so on.

# TODO: There is a way to give provide a custom help for a specific
# kind of completion expected (frame number, file name, breakpoint
# number...), which is can be supplied completion help, ^Xh is
# entered. This is called a "tag group" and below we have a "frame"
# group. We haven't added the description for it, because too many of
# the zsh-specific things I, rocky, can't figure it out. If
# someone else wants do add, by all means, please do.
typeset -A _Dbg_complete_level_1_data
_Dbg_complete_level_1() {
    if [[ -n ${_Dbg_complete_level_1_data[$1]} ]] ; then
	typeset completion
	completion=${_Dbg_complete_level_1_data[$1]}
	if [[ ${completion[0,1]} == '-Q' ]] ; then
	    opt=${completion[0,1]}
	    completion=$(${completion[2,-1]})
	    compadd $opt -- "$completion"
	elif [[ ${completion[0,1]} == '-f' ]] ; then
	    typeset -a array
	    array=($(${completion[2,-1]}))
	    compadd -V frame ${array[@]}
	elif [[ ${completion[0,1]} == '-a' ]] ; then
	    typeset -a array
	    array=($(${completion[2,-1]}))
	    compadd -- ${array[@]}
	elif [[ ${completion[0,1]} == '-A' ]] ; then
	    typeset -a array
	    array=($(${completion[2,-1]}))
	    compadd -Q -- ${array[@]}
	else
	    compadd -- ${_Dbg_complete_level_1_data[$1]}
	fi
    fi
}

# Interactive completion for level_2. This is completion for debugger
# subcommand arguments like "set basename", "info breakpoints" and so
# on.
typeset -A _Dbg_complete_level_2_data
_Dbg_complete_level_2() {
    if [[ -n ${_Dbg_complete_level_2_data[$1]} ]] ; then
	typeset completion
	completion=${_Dbg_complete_level_2_data[$1]}
	if [[ ${completion[0,1]} == '-Q' ]] ; then
	    opt=${completion[0,1]}
	    completion=$(${completion[2,-1]})
	    compadd $opt -- "$completion"
	elif [[ ${completion[0,1]} == '-a' ]] ; then
	    typeset -a array
	    array=($(${completion[2,-1]}))
	    compadd -- ${array[@]}
	else
	    compadd -- ${_Dbg_complete_level_2_data[$1]}
	fi
    fi
}

zle -C zshdb_complete menu-expand-or-complete _Dbg_complete_level_0
# zle -C zshdb_complete list-choices _Dbg_complete_level_0
bindkey '^i' zshdb_complete

#;;; Local Variables: ***
#;;; mode:shell-script ***
#;;; End: ***
