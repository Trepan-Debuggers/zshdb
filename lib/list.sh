# -*- shell-script -*-
# debugger source-code listing routines
#
#   Copyright (C) 2008, 2009, 2010, 2011
#    Rocky Bernstein <rocky@gnu.org>
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

# List search commands/routines

# Last search pattern used.
typeset _Dbg_last_search_pat

# The current line to be listed. A 0 value indicates we should set
# from _Dbg_frame_last_lineno
typeset -i _Dbg_listline=0

# list $3 lines starting at line $2 of file $1. If $1 is '', use
# $_Dbg_frame_last_filename value.  If $3 is ommited, print $_Dbg_set_listsize
# lines. if $2 is omitted, use global variable $_Dbg_frame_last_lineno.
_Dbg_list() {
    typeset filename
    if (( $# > 0 )) ; then
	filename=$1
    else
	filename=$_Dbg_frame_last_filename
    fi

    if [[ $2 == '.' ]]; then
	_Dbg_listline=$_Dbg_frame_last_lineno
    elif [[ -n $2 ]] ; then
	_Dbg_listline=$2
    elif (( 0 == _Dbg_listline )) ; then
	_Dbg_listline=$_Dbg_frame_last_lineno
    fi
    (( _Dbg_listline==0 && _Dbg_listline++ ))

    typeset -i cnt
    cnt=${3:-$_Dbg_set_listsize}
    typeset -i n
    n=$((_Dbg_listline+cnt-1))

    _Dbg_readin_if_new "$filename"

    typeset -i max_line
    max_line=$(_Dbg_get_maxline "$filename")
    if (( $? != 0 )) ; then
	_Dbg_errmsg "internal error getting number of lines in $filename"
	return 1
    fi

    if (( _Dbg_listline > max_line )) ; then
      _Dbg_errmsg \
	"Line number $_Dbg_listline out of range;" \
      "$filename has $max_line lines."
      return 1
    fi

    typeset source_line
    typeset frame_fullfile
    frame_fullfile=${_Dbg_file2canonic[$_Dbg_frame_last_filename]}
    
    for ((  ; _Dbg_listline <= n && _Dbg_listline <= max_line \
            ; _Dbg_listline++ )) ; do
     typeset prefix='    '
     _Dbg_get_source_line $_Dbg_listline "$filename"

       (( _Dbg_listline == _Dbg_frame_last_lineno )) \
         && [[ $fullname == $frame_fullfile ]] &&  prefix=' => '
      _Dbg_printf "%3d:%s%s" $_Dbg_listline "$prefix" "$source_line"
    done
    (( _Dbg_listline > max_line && _Dbg_listline-- ))
    return 0
}

_Dbg_list_columns() {
    typeset colsep='  '
    (($# > 0 )) && { colsep="$1"; shift; }
    typeset -i linewidth
    # 2 below is the initial prefix
    if (($# > 0 )) && ; then 
	msg=$1
	shift
    else
	msg=_Dbg_msg
    fi
    if (($# > 0 )) ; then
	((linewidth=$1-2)); 
	shift
    else
	((linewidth=_Dbg_set_linewidth-2))
    fi
    (($# != 0)) && return 1
    typeset -a columnized; columnize $linewidth "$colsep"
    typeset -i i
    for ((i=0; i<${#columnized[@]}; i++)) ; do 
	$msg "  ${columnized[i]}"
    done

}
_Dbg_list_locals() {
    typeset -a list
    list=(${(k)parameters[(R)*local*]})
    typeset -i rc=$?
    (( rc != 0 )) && return $rc
    _Dbg_list_columns
}

_Dbg_list_globals() {
    typeset -a list
    list=(${(k)parameters[(R)^*local*]})
    typeset -i rc=$?
    (( rc != 0 )) && return $rc
    _Dbg_list_columns
}

_Dbg_list_typeset_attr() {
    typeset -a list
    list=( $(_Dbg_get_typeset_attr '+p' $*) )
    typeset -i rc=$?
    (( rc != 0 )) && return $rc
    _Dbg_list_columns
}
