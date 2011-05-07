# -*- shell-script -*-
# shell.sh - helper routines for 'shell' debugger command
#
#   Copyright (C) 2011 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_shell_temp_profile="$_Dbg_tmpdir/.zshenv"

zmodload -ap zsh/parameter parameters
_Dbg_shell_variable_names() {
    echo ${(k@)parameters}
}

_Dbg_shell_variable_typeset() {
    typeset var=$1
    case ${parameters[$var]} in
	*export* )
	    return 2
	    ;;
	*special* )
	    return 3
	    ;;
	# This must come before local and *
	*readonly*) 
	    return 1
	    ;;
	*local* | *)
	    return 0
	    ;;
    esac
    return 3
}

_Dbg_shell_append_typesets() {
    [[ -z $_Dbg_var_names ]] && _Dbg_var_names=(${(k@)parameters[@]})
    local _Dbg_profile
    _Dbg_profile=${1:-$_Dbg_shell_temp_profile}
    typeset _Dbg_set_debug
    _Dbg_set_debug=${2:-1}

    typeset -A exclude_list
    typeset var_set_cmd
    exclude_list[exclude_list]=1
    for var_name in ${_Dbg_var_names[@]}; do
	[[ -z $var_name ]] && continue
	((_Dbg_set_debug)) && [[ $var_name =~ ^_Dbg_ ]] && continue
	((exclude_list[var_name])) && continue
	_Dbg_shell_variable_typeset "$var_name"
	case $? in 
	    0)
		typeset -p $var_name 2>/dev/null
		;;
	    1)
		print "typeset -p ${var_name} 2>/dev/null 1>&2 || $(typeset -p $var_name)" 2>/dev/null
		;;
	    *)
		;;
	esac
    done >>$_Dbg_profile
}

_Dbg_shell_append_fn_typesets() {
    typeset -a words 
    typeset -pf | while read -a words ; do 
	[[ declare != ${words[0]} ]] && continue
	fn_name=${words[2]%%=*}
	((0 == _Dbg_set_debug)) && [[ $fn_name =~ ^_Dbg_ ]] && continue	
	flags=${words[1]}
	echo $(typeset -pf ${fn_name} 2>/dev/null)
    done >>$_Dbg_shell_temp_profile
}

_Dbg_shell_new_shell_profile() {
    typeset -i _Dbg_o_vars; _Dbg_o_vars=${1:-1}
    typeset -i _Dbg_o_fns;  _Dbg_o_fns=${2:-1}

    echo '# debugger shell profile' > $_Dbg_shell_temp_profile

    ((_Dbg_o_vars)) && _Dbg_shell_append_typesets

    # Add where file to allow us to restore info and
    # Routine use can call to mark which variables should persist
    typeset -p _Dbg_restore_info >> $_Dbg_shell_temp_profile
    echo "source ${_Dbg_libdir}/data/shell.sh" >> $_Dbg_shell_temp_profile

    ((_Dbg_o_fns))  && _Dbg_shell_append_fn_typesets

}
