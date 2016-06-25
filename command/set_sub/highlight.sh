# -*- shell-script -*-
# "set highlight" debugger command
#
#   Copyright (C) 2011, 2014-2016 Rocky Bernstein <rocky@gnu.org>
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

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && top_dir='../..' || top_dir=${dirname}/../..
    for lib_file in help alias ; do source $top_dir/lib/${lib_file}.sh; done
    typeset -A _Dbg_command_help_set
    typeset -A _Dbg_debugger_set_commands
fi

typeset -A _Dbg_complete_level_2_data
_Dbg_complete_level_2_data[set_highlight]='dark light off reset'

_Dbg_help_add_sub set highlight \
'
**set** **highlight** [**dark**|**light**|**off**|**reset**]

Set using terminal highlight.

Use **reset** to set highlighting on and force a redo of syntax
highlighting of already cached files. This may be needed if the
debugger was started without syntax highlighting initially.

**dark** sets sets for highlighting for a terminal with a dark background and
**light** set for highlighting for a terminal with a light background.

See also:
---------

**show highlight**.
'

_Dbg_do_set_highlight() {
    if ( pygmentize --version || pygmentize -V ) 2>/dev/null 1>/dev/null ; then
	:
    else
	_Dbg_errmsg "Can't run pygmentize. Setting forced off"
	return 1
    fi
    typeset onoff=${1:-'light'}
    case $onoff in
	on | light )
	    _Dbg_set_highlight='light'
	    _Dbg_filecache_reset
	    _Dbg_readin $_Dbg_frame_last_filename
	    ;;
	dark )
	    _Dbg_set_highlight='dark'
	    _Dbg_filecache_reset
	    _Dbg_readin $_Dbg_frame_last_filename
	    ;;
	off | 0 )
	    _Dbg_set_highlight=''
	    ;;
	reset )
	    [[ -z $_Dbg_set_highlight ]] && _Dbg_set_highlight='light'
	    _Dbg_filecache_reset
	    _Dbg_readin $_Dbg_frame_last_filename
	    ;;
	* )
	    _Dbg_errmsg '"dark", "light", "off", or "reset" expected.'
	    return 1
    esac
    _Dbg_do_show highlight
    return 0
}
