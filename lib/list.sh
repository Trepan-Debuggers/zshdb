# -*- shell-script -*-
# list.sh - Bourne Again Shell Debugger list/search commands
#   Copyright (C) 2008 Rocky Bernstein rocky@gnu.org
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

# List search commands/routines

# Last search pattern used.
typeset _Dbg_last_search_pat

# current line to be listed
typeset -i _Dbg_listline

# list $3 lines starting at line $2 of file $1. If $1 is '', use
# $_cur_source_file value.  If $3 is ommited, print $_Dbg_listsize
# lines. if $2 is omitted, use global variable $_curline.

_Dbg_list() {
    typeset filename
    if (( $# > 0 )) ; then
	filename=$1
    else
	filename=$_Dbg_frame_last_file
    fi

    if [[ $2 = '.' ]]; then
	_Dbg_listline=$Dbg_frame_last_lineno
    elif [[ -n $2 ]] ; then
      _Dbg_listline=$2
    else
	_Dbg_listline=$_Dbg_frame_last_lineno
    fi
    (( _Dbg_listline==0 )) && ((_Dbg_listline++))

    typeset -i cnt
    cnt=${3:-$_Dbg_listsize}
    typeset -i n
    n=$((_Dbg_listline+cnt-1))

    _Dbg_readin_if_new "$filename"

    typeset -i max_line
    max_line=$(_Dbg_get_maxline $filename)
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
    frame_fullfile=${_Dbg_file2canonic[$_Dbg_frame_last_file]}
    
    for ((  ; (( _Dbg_listline <= n && _Dbg_listline <= max_line )) \
            ; _Dbg_listline++ )) ; do
     typeset prefix='    '
     _Dbg_get_source_line $_Dbg_listline $filename

       (( _Dbg_listline == _Dbg_frame_last_lineno )) \
         && [[ $fullname == $frame_fullfile ]] &&  prefix=' => '
      _Dbg_printf "%3d:%s%s" $_Dbg_listline "$prefix" "$source_line"
    done
    (( _Dbg_listline > max_line && _Dbg_listline-- ))
    return 0
}
