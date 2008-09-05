# -*- shell-script -*-
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

# Add breakpoint(s) at given line number of the current file.  $1 is
# the line number or _curline if omitted.  $2 is a condition to test
# for whether to stop.

_Dbg_help_add break \
'break [LOCSPEC]	-- Set a breakpoint at LOCSPEC. 

If no location specification is given, use the current line.'

_Dbg_do_break() {

  typeset -i is_temp=$1
  shift

  typeset -i n;
  if (( $# > 0 )) ; then 
      n=$1
  else
      _Dbg_frame_lineno; n=$?
  fi
  shift

  typeset condition=${1:-''};
  if [[ "$n" == 'if' ]]; then
      _Dbg_frame_lineno; n=$?
  elif [[ -z $condition ]] ; then
    condition=1
  elif [[ $condition == 'if' ]] ; then
    shift
  fi
  if [[ -z $condition ]] ; then
    condition=1
  else 
    condition="$*"
  fi

  typeset filename
  typeset -i line_number
  typeset full_filename

  _Dbg_linespec_setup $n

  if [[ -n $full_filename ]]  ; then 
    if (( $line_number ==  0 )) ; then 
      _Dbg_errmsg "There is no line 0 to break at."
    else 
      _Dbg_check_line $line_number "$full_filename"
      (( $? == 0 )) && \
	_Dbg_set_brkpt "$full_filename" "$line_number" $is_temp "$condition"
    fi
  else
    _Dbg_file_not_read_in $filename
  fi
}

# delete brkpt(s) at given file:line numbers. If no file is given
# use the current file.
_Dbg_do_clear_brkpt() {
  # set -x
  typeset -r n=${1:-$_curline}

  typeset filename
  typeset -i line_number
  typeset full_filename

  _Dbg_linespec_setup $n

  if [[ -n $full_filename ]] ; then 
    if (( $line_number ==  0 )) ; then 
      _Dbg_msg "There is no line 0 to clear."
    else 
      _Dbg_check_line $line_number "$full_filename"
      if (( $? == 0 )) ; then
	_Dbg_unset_brkpt "$full_filename" "$line_number"
	typeset -r found=$?
	if [[ $found != 0 ]] ; then 
	  _Dbg_msg "Removed $found breakpoint(s)."
	else 
	  _Dbg_msg "Didn't find any breakpoints to remove at $n."
	fi
      fi
    fi
  else
    _Dbg_file_not_read_in $filename
  fi
}

# list breakpoints and break condition.
# If $1 is given just list those associated for that line.
_Dbg_do_list_brkpt() {
    
  if (( $# != 0  )) ; then 
      typeset brkpt_num=''
      if [[ $brkpt_num == [0-9]* ]] ; then
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
	      $source_file ${_Dbg_brkpt_line[$i]}
	  if [[ ${_Dbg_brkpt_cond[$i]} != '1' ]] ; then
	      _Dbg_printf "\tstop only if %s" "${_Dbg_brkpt_cond[$i]}"
	  fi
	  _Dbg_print_brkpt_count ${_Dbg_brkpt_count[$i]}
	  return 0
      fi
      return 1
  fi

  if (( ${#_Dbg_brkpt_line[@]} != 0 )); then
    typeset -i i

    _Dbg_msg "Num Type       Disp Enb What"
    for (( i=1; (( i <= _Dbg_brkpt_max )) ; i++ )) ; do
      typeset source_file=${_Dbg_brkpt_file[$i]}
      if [[ -n ${_Dbg_brkpt_line[$i]} ]] ; then
	source_file=$(_Dbg_adjust_filename "$source_file")
	_Dbg_printf "%-3d breakpoint %-4s %-3s %s:%s" $i \
	  ${_Dbg_keep[${_Dbg_brkpt_onetime[$i]}]} \
	  ${_Dbg_yn[${_Dbg_brkpt_enable[$i]}]} \
	  $source_file ${_Dbg_brkpt_line[$i]}
	if [[ ${_Dbg_brkpt_cond[$i]} != '1' ]] ; then
	  _Dbg_printf "\tstop only if %s" "${_Dbg_brkpt_cond[$i]}"
	fi
	if (( _Dbg_brkpt_count[$i] != 0 )) ; then
	  _Dbg_print_brkpt_count ${_Dbg_brkpt_count[$i]}
	fi
      fi
    done
  else
    _Dbg_errmsg "No breakpoints have been set."
  fi
}

_Dbg_alias_add b break

