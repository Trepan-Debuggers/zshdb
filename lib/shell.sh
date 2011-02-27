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
_Dbg_get_all_variables() {
    IFS=$'\n' lines=($(typeset -p))
}

# Get variable name from word. This is the part before the =.
# For example: typeset CDPATH='' -> CDPATH
_Dbg_get_typeset_varname() {
    token=$1
    if [[ $token =~ ^(.*)= ]] ; then
	varname=${match[0]}
    else
	varname=$token
    fi
}

_Dbg_filter_typeset() {
    typeset -i i=0
    typeset -i k=-1
    typeset -i n=${#lines[@]}
    typeset -i skip_next=0
    typeset -i is_array=0
    typeset varname
    typeset -a words
    for ((i=0; i<n; i++)) ; do
	IFS=' ' read -A words <<< ${lines[i]}
	if [[ ${words[0]} == 'typeset' ]] ; then
	    is_array=0
	    skip_next=0
	    # Handle typeset declarations
	    typeset -i j
	    for ((j=1; j<n ; j++)); do
		if [[ ${words[j]} =~ ^-.*a ]] ; then
		    is_array=1
		fi
		if [[ ${words[j]} =~ ^-.*r ]] ; then
		    break
		elif [[ ! ${words[j]} =~ ^- ]] ; then
		    _Dbg_get_typeset_varname ${words[j]}
		    ((j=n))
		fi
	    done
	    if ((j < n )); then
		# Add guard around read-only variables
		_Dbg_get_typeset_varname ${words[j+1]}
		# Check to see that varname is a legitimate name
		if [[ $varname =~ ^[A-Za-z_] ]] ; then
		    newlines[k++]="typeset -p ${varname} 2>/dev/null 1>&2 || ${lines[i]}"
		else
		    ((is_array)) && skip_next=1
		fi
		continue
	    else
		# Check to see that varname is a legitimate name
		if [[ ! $varname =~ ^[A-Za-z_] ]] ; then
		    # Nope, so don't save the line
		    continue
		fi
	    fi
	fi
	((!skip_next)) && newlines[k++]=${lines[i]}
	skip_next=0
    done
}


# print_lines() {
#     typeset -i i=0
#     for line in "$@" ; do 
# 	print $line
#     done
#     echo '-------------------------------'
# }

# typeset -a lines
# typeset -a newlines
# lines=(
#     "typeset -ar funcstack"
#     "typeset CDPATH=''" 
#     "typeset -i10 -r '#'=0"
#     "typeset -i10 -r TTYIDLE=0"
#     "typeset -i10 -x COLUMNS=80"
# )
# print_lines ${lines[@]}
# _Dbg_filter_typeset
# print_lines ${newlines[@]}
