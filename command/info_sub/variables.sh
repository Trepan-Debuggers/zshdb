# -*- shell-script -*-
# "info variables" debugger command
#
#   Copyright (C) 2010, 2014, 2016 Rocky Bernstein rocky@gnu.org
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

_Dbg_help_add_sub info program '
**info variables** [*property*]

list global and static variable names.

Variable lists by property.
*property* is one of:

	array, export, fixed, float, function, hash, integer, or readonly

' 1

typeset _Dbg_info_var_attrs="array, export, fixed, float, function, hash, integer, or readonly"
_Dbg_do_info_variables() {
    if (($# > 0)) ; then
        typeset kind="$1"
        shift
        case "$kind" in
            a | ar | arr | arra | array )
                _Dbg_do_list_typeset_attr '+a' $*
                return 0
                ;;
            e | ex | exp | expor | export )
                _Dbg_do_list_typeset_attr '+x' $*
                return 0
                ;;
            fu|fun|func|funct|functi|functio|function )
                _Dbg_do_list_typeset_attr '+f' $*
                return 0
                ;;
            fi|fix|fixe|fixed )
                _Dbg_do_list_typeset_attr '+F' $*
                return 0
                ;;
            fl|flo|floa|float )
                _Dbg_do_list_typeset_attr '+E' $*
                return 0
                ;;
# 	    g | gl | glo | glob | globa | global )
# 		_Dbg_do_list_globals
# 		return 0
# 		;;
            h | ha | has | hash )
                _Dbg_do_list_typeset_attr '+A' $*
                return 0
                ;;
            i | in | int| inte | integ | intege | integer )
                _Dbg_do_list_typeset_attr '+i' $*
                return 0
                ;;
# 	    l | lo | loc | loca | local | locals )
# 		_Dbg_do_list_locals
# 		return 0
# 		;;
            r | re | rea| read | reado | readon | readonl | readonly )
                _Dbg_do_list_typeset_attr '+r' $*
                return 0
                ;;
            * )
                _Dbg_errmsg "Don't know how to list variable type: $kind"
        esac
    fi
    _Dbg_errmsg "Need to specify a variable class which is one of: "
    _Dbg_errmsg "$_Dbg_info_var_attrs"
    return 1
}
