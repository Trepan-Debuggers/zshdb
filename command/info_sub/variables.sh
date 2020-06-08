# -*- shell-script -*-
# "info variables" debugger command
#
#   Copyright (C) 2010, 2014, 2016, 2019-2020 Rocky Bernstein rocky@gnu.org
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

_Dbg_help_add_sub info variables '
**info variables** [*property*]

list global and static variable names.

Variable lists by property.
*property* is an abbreviation of one of:

	arrays, exports, fixed, floats, functions, integers, hash, or readonly

Examples:
---------

    info variables             # show all variables
    info variables readonly    # show only read-only variables
    info variables integer     # show only integer variables
    info variables functions   # show only functions

' 1

typeset _Dbg_info_var_attrs="array, export, fixed, float, function, hash, integer, or readonly"
_Dbg_do_info_variables() {
    if (($# > 1)) ; then
        typeset kind="$1"
	# Remove "info variables xxx"
        shift; shift; shift
        case "$kind" in
            a | ar | arr | arra | array | arrays )
                _Dbg_do_list_typeset_attr '+a' $@
                return 0
                ;;
            e | ex | exp | expor | export | exports )
                _Dbg_do_list_typeset_attr '+x' $@
                return 0
                ;;
            fu|fun|func|funct|functi|functio|function|functions )
                _Dbg_do_list_typeset_attr '+f' $@
                return 0
                ;;
            fi|fix|fixe|fixed )
                _Dbg_do_list_typeset_attr '+F' $@
                return 0
                ;;
            fl|flo|floa|float|floats)
                _Dbg_do_list_typeset_attr '+E' $@
                return 0
                ;;
# 	    g | gl | glo | glob | globa | global )
# 		_Dbg_do_list_globals
# 		return 0
# 		;;
            h | ha | has | hash )
                _Dbg_do_list_typeset_attr '+A' $@
                return 0
                ;;
            i | in | int| inte | integ | intege | integer | integers )
                _Dbg_do_list_typeset_attr '+i' $@
                return 0
                ;;
# 	    l | lo | loc | loca | local | locals )
# 		_Dbg_do_list_locals
# 		return 0
# 		;;
            # p | pr | pro| prop | prope | proper | propert | properti | propertie | properties )
            #     _Dbg_do_list_typeset_attr '+p' $@
            #     return 0
            #   ;;
            r | re | rea| read | reado | readon | readonl | readonly )
                _Dbg_do_list_typeset_attr '+r' $@
                return 0
                ;;
            * )
                _Dbg_errmsg "Don't know how to list variable type: $kind"
        esac
    fi
    _Dbg_errmsg "Need to specify a variable class which is one of: "
    _Dbg_errmsg "$_Dbg_info_var_attrs"
    return 0
}
