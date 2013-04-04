# -*- shell-script -*-
# display.sh - Debugger display routines
#
#   Copyright (C) 2010, 2013 Rocky Bernstein
#   rocky@gnu.org
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
#   along with this Program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

#================ VARIABLE INITIALIZATIONS ====================#

# Display data structures
typeset -a  _Dbg_disp_exp; _Dbg_disp_exp=() # Watchpoint expressions
typeset -ia _Dbg_disp_enable; _Dbg_disp_enable=() # 1/0 if enabled or not
typeset -i  _Dbg_disp_max=0     # Needed because we can't figure out what
                                # the max index is and arrays can be sparse


#========================= FUNCTIONS   ============================#

_Dbg_save_display() {
  typeset -p _Dbg_disp_exp >> $_Dbg_statefile
  typeset -p _Dbg_disp_enable >> $_Dbg_statefile
  typeset -p _Dbg_disp_max >> $_Dbg_statefile
}

# Enable/disable display by entry numbers.
_Dbg_disp_enable_disable() {
    if (($# < 2)) ; then
	_Dbg_errmsg "Expecting at least two parameters. Got: ${#}."
	return 1
    fi
    typeset -i on=$1
    typeset en_dis=$2
    shift; shift

    typeset to_go="$@"
    typeset i
    for i in $to_go ; do
	case $i in
	[0-9]* )
		_Dbg_enable_disable_display $on $en_dis $i
		;;
	* )
		_Dbg_errmsg "Invalid entry number $i skipped"
		;;
	esac
    done
    return 0
}

_Dbg_eval_all_display() {
  typeset -i i
  for (( i=0; i < _Dbg_disp_max ; i++ )) ; do
    if [ -n "${_Dbg_disp_exp[$i]}" ] \
      && [[ ${_Dbg_disp_enable[i]} != 0 ]] ; then
      _Dbg_printf_nocr "%2d: %s = " $i "${_Dbg_disp_exp[i]}"
      typeset -i _Dbg_show_eval_rc; _Dbg_show_eval_rc=0
      _Dbg_do_eval "_Dbg_msg ${_Dbg_disp_exp[i]}"
    fi
  done
}

# Enable/disable display(s) by entry numbers.
_Dbg_enable_disable_display() {
  typeset -i on=$1
  typeset en_dis=$2
  typeset -i i=$3
  if [ -n "${_Dbg_disp_exp[$i]}" ] ; then
    if [[ ${_Dbg_disp_enable[$i]} == $on ]] ; then
      _Dbg_errmsg "Display entry $i already ${en_dis}, so nothing done."
    else
      _Dbg_write_journal_eval "_Dbg_disp_enable[$i]=$on"
      _Dbg_msg "Display entry $i $en_dis."
    fi
  else
    _Dbg_errmsg "Display entry $i doesn't exist, so nothing done."
  fi
}
