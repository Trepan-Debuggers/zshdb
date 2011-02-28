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

zmodload -ap zsh/parameter parameters
_Dbg_shell_variable_names() {
    echo ${(k@)parameters}
}

_Dbg_shell_variable_typeset() {
    local var=$1
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
    local _Dbg_set_debugging
    _Dbg_set_debugging=${2:-1}

    typeset -A exclude_list
    typeset var_set_cmd
    exclude_list[exclude_list]=1
    for var_name in ${_Dbg_var_names[@]}; do
	[[ -z $var_name ]] && continue
	((_Dbg_set_debugging)) && [[ $var_name =~ ^_Dbg_ ]] && continue
	((exclude_list[var_name])) && continue
	_Dbg_shell_variable_typeset "$var_name"
	case $? in 
	    0)
		typeset -p $var_name >> $_Dbg_profile 2>/dev/null
		;;
	    1)
		echo "typeset -p ${var_name} 2>/dev/null 1>&2 || $(typeset -p $var_name)" >> $_Dbg_profile 2>/dev/null
		;;
	    *)
		;;
	esac
    done
}

# setopt ksharrays
# _Dbg_set_debugging=1
# _Dbg_shell_temp_profile='/tmp/test-profile'
# rm $_Dbg_shell_temp_profile
# typeset -a _Dbg_var_names
# # _Dbg_var_names=(AMAZON_ACCESS_KEY_ID ! '#' '$' '*' - 0 '?' @)
# _Dbg_shell_append_typesets /tmp/test-profile 1


# test_var_names() {
#     local testing
#     typeset -r read_only='abc'
#     typeset -i foo=0
#     for var in PATH foo testing CDPATH read_only ; do
# 	$(_Dbg_shell_variable_typeset $var)
# 	rc=$?
# 	if ((0 == $rc)) ; then
# 	    typeset -p $var
# 	elif ((1 == $rc)) ; then
# 	    print "readonly"
# 	    typeset -p $var
# 	fi
#     done
# }

# test_var_names

# test_it() {
#     for param type in "${(kv@)parameters}" ; do
# 	case $type in
# 	    *special*)
# 		echo $param $type ${parameters[$param]}
# 		continue
# 		;;
# 	esac
#     done
# }

# test_it
