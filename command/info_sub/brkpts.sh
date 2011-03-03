# -*- shell-script -*-
# gdb-like "info program" debugger command
#
#   Copyright (C) 2010 Rocky Bernstein rocky@gnu.org
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

# list breakpoints and break condition.
# If $1 is given just list those associated for that line.

_Dbg_do_info_brkpts() {
    
  if (( $# != 0  )) ; then 
      typeset brkpt_num=''
      if [[ $brkpt_num != [0-9]* ]] ; then
	  _Dbg_errmsg "Bad breakpoint number $brkpt_num."
      elif [[ -z ${_Dbg_brkpt_file[$brkpt_num]} ]] ; then
	  _Dbg_errmsg "Breakpoint entry $brkpt_num is not set."
      else
	  typeset -r -i i=$brkpt_num
	  typeset source_file=${_Dbg_brkpt_file[$i]}
	  source_file=$(_Dbg_adjust_filename "$source_file")
	  _Dbg_msg "Num Type       Disp Enb What"
	  _Dbg_printf "%-3d breakpoint %-4s %-3s %s:%s" $i \
	      ${_Dbg_keep[${_Dbg_brkpt_onetime[$i]}]} \
	      ${_Dbg_yn[${_Dbg_brkpt_enable[$i]}]} \
	      "$source_file" ${_Dbg_brkpt_line[$i]}
	  if [[ ${_Dbg_brkpt_cond[$i]} != '1' ]] ; then
	      _Dbg_printf "\tstop only if %s" "${_Dbg_brkpt_cond[$i]}"
	  fi
	  _Dbg_print_brkpt_count $i
	  return 0
      fi
      return 1
  fi

  if (( _Dbg_brkpt_count > 0 )); then
      typeset -i i
      
      _Dbg_msg "Num Type       Disp Enb What"
      for (( i=1; i <= _Dbg_brkpt_max ; i++ )) ; do
	  source_file="${_Dbg_brkpt_file[$i]}"
      if [[ -n ${_Dbg_brkpt_line[$i]} ]] ; then
	  source_file=$(_Dbg_adjust_filename "$source_file")
	  _Dbg_printf "%-3d breakpoint %-4s %-3s %s:%d" $i \
	      ${_Dbg_keep[${_Dbg_brkpt_onetime[$i]}]} \
	      ${_Dbg_yn[${_Dbg_brkpt_enable[$i]}]} \
	      "$source_file" ${_Dbg_brkpt_line[$i]}
	  if [[ ${_Dbg_brkpt_cond[$i]} != '1' ]] ; then
	      _Dbg_printf "\tstop only if %s" "${_Dbg_brkpt_cond[$i]}"
	  fi
	  _Dbg_print_brkpt_count $i
      fi
      done
  else
      _Dbg_errmsg 'No breakpoints have been set.'
  fi
}
