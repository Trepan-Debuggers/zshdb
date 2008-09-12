# -*- shell-script -*-
#
#   Copyright (C) 2008 Rocky Bernstein  rocky@gnu.org
#
#   zshdb is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your
#   option) any later version.
#
#   zshdb is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#   
#   You should have received a copy of the GNU General Public License along
#   with zshdb; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.

#================ VARIABLE INITIALIZATIONS ====================#

typeset -a _Dbg_keep
_Dbg_keep=('keep' 'del')  

# Note: we loop over possibly sparse arrays with _Dbg_brkpt_max by adding one
# and testing for an entry. Could add yet another array to list only 
# used indices. Zsh is kind of primitive.

# Breakpoint data structures

# Line number of breakpoint $i
typeset -a _Dbg_brkpt_line; _Dbg_brkpt_line=()

# Number of breakpoints.
typeset -i _Dbg_brkpt_count=0

# filename of breakpoint $i
typeset -a  _Dbg_brkpt_file; _Dbg_brkpt_file=()

# 1/0 if enabled or not
typeset -a  _Dbg_brkpt_enable; _Dbg_brkpt_enable=()

# Number of times hit
typeset -a _Dbg_brkpt_counts; _Dbg_brkpt_counts=()

# Is this a onetime break?
typeset -a _Dbg_brkpt_onetime; _Dbg_brkpt_onetime=()

# Condition to eval true in order to stop.
typeset -a  _Dbg_brkpt_cond; _Dbg_brkpt_cond=()

# Needed because we can't figure out what the max index is and arrays
# can be sparse.
typeset -i  _Dbg_brkpt_max=0 

# Maps a resolved filename to a list of beakpiont line numbers in that file
typeset -A _Dbg_brkpt_file2linenos; _Dbg_brkpt_file2linenos=()

# Maps a resolved filename to a list of breakpoint entries.
typeset -A _Dbg_brkpt_file2brkpt; _Dbg_brkpt_file2brkpt=()
 
# Note: we loop over possibly sparse arrays with _Dbg_brkpt_max by adding one
# and testing for an entry. Could add yet another array to list only 
# used indices. Zsh is kind of primitive.

#========================= FUNCTIONS   ============================#

# Error message for file not read in
_Dbg_file_not_read_in() {
    typeset -r filename=$(_Dbg_adjust_filename "$1")
    _Dbg_msg "File $filename not found in read-in files."
    _Dbg_msg "See 'info files' for a list of known files and"
    _Dbg_msg "'load' to read in a file."
}

_Dbg_save_breakpoints() {
  typeset file
  for file in ${_Dbg_filenames[@]} ; do  
    typeset filevar="`_Dbg_file2var $file`"
    typeset -p _Dbg_brkpt_$filevar >> $_Dbg_statefile 2>/dev/null
  done        
  typeset -p _Dbg_brkpt_line >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_file >> $_Dbg_statefile 
  typeset -p _Dbg_brkpt_cond >> $_Dbg_statefile 
  typeset -p _Dbg_brkpt_counts >> $_Dbg_statefile 
  typeset -p _Dbg_brkpt_enable >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_onetime >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_max >> $_Dbg_statefile

}

# Start out with general break/watchpoint functions first...

# Enable/disable breakpoint or watchpoint by entry numbers.
_Dbg_enable_disable() {
  if (($# == 0)) ; then
    _Dbg_errmsg "Expecting a list of breakpoint/watchpoint numbers. Got none."
    return 1
  fi
  typeset -i on=$1
  typeset en_dis=$2
  shift; shift

  if [[ $1 = 'display' ]] ; then
    shift
    typeset to_go="$@"
    typeset i
    for i in $to_go ; do 
      if [[ $i == [0-9]* ]] ; then
	  _Dbg_enable_disable_display $on $en_dis $i
      else
	  _Dbg_errmsg "Invalid entry number skipped: $i"
      fi
    done
    return 0
  elif [[ $1 = 'action' ]] ; then
    shift
    typeset to_go="$@"
    typeset i
    for i in $to_go ; do 
      if [[ $i == [0-9]* ]] ; then
	  _Dbg_enable_disable_action $on $en_dis $i
      else
	  _Dbg_errmsg "Invalid entry number skipped: $i"
      fi
    done
    return 0
  fi

  typeset to_go="$@"
  typeset i
  for i in $to_go ; do 
      if [[ $i == [0-9]* ]] ; then
          _Dbg_enable_disable_brkpt $on $en_dis $i
      # elsif # Check for watch-pat
      #   _Dbg_enable_disable_watch $on $en_dis ${del:0:${#del}-1}
      else
	  _Dbg_errmsg "Invalid entry number skipped: $i"
      fi
  done
  return 0
}

function _Dbg_print_brkpt_count {
  typeset -i i
  i=$1
  if (( _Dbg_brkpt_counts[i] != 0 )) ; then
    if (( _Dbg_brkpt_counts[i] == 1 )) ; then 
      _Dbg_printf '    breakpoint already hit 1 time'
    else
      _Dbg_printf "    breakpoint already hit %d times" ${_Dbg_brkpt_counts[$i]}
    fi
  fi
}

# clear all brkpts
_Dbg_clear_all_brkpt() {

  typeset -i k
  for (( k=0; (( k < ${#_Dbg_filenames[@]} )) ; k++ )) ; do
    typeset filename=${_filename[$k]}
    typeset filevar="`_Dbg_file2var $filename`"
    typeset brkpt_a="_Dbg_brkpt_${filevar}"
    _Dbg_write_journal_eval "unset ${brkpt_a}[$k]"
  done
  _Dbg_write_journal_eval "_Dbg_brkpt_line=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_cond=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_file=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_enable=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_counts=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_onetime=()"
}

# Internal routine to a set breakpoint unconditonally. 

_Dbg_set_brkpt() {
  typeset source_file="$1"
  typeset -ir lineno=$2
  typeset -ir is_temp=$3
  typeset -r  condition=${4:-1}

  # Increment brkpt_max here because we are 1-origin
  ((_Dbg_brkpt_max++))
  ((_Dbg_brkpt_count++))

  _Dbg_brkpt_line[$_Dbg_brkpt_max]=$lineno
  _Dbg_brkpt_file[$_Dbg_brkpt_max]="$source_file"
  _Dbg_brkpt_cond[$_Dbg_brkpt_max]="$condition"
  _Dbg_brkpt_onetime[$_Dbg_brkpt_max]=$is_temp
  _Dbg_brkpt_counts[$_Dbg_brkpt_max]=0
  _Dbg_brkpt_enable[$_Dbg_brkpt_max]=1

  typeset dq_source_file=$(_Dbg_esc_dq "$source_file")
  typeset dq_condition=$(_Dbg_esc_dq "$condition")
  _Dbg_write_journal "_Dbg_brkpt_line[$_Dbg_brkpt_max]=$lineno"
  _Dbg_write_journal "_Dbg_brkpt_file[$_Dbg_brkpt_max]=\"$dq_source_file\""
  _Dbg_write_journal "_Dbg_brkpt_cond[$_Dbg_brkpt_max]=\"$dq_condition\""
  _Dbg_write_journal "_Dbg_brkpt_onetime[$_Dbg_brkpt_max]=$is_temp"
  _Dbg_write_journal "_Dbg_brkpt_counts[$_Dbg_brkpt_max]=0"
  _Dbg_write_journal "_Dbg_brkpt_enable[$_Dbg_brkpt_max]=1"

  # Add line number with a leading and trailing space. Delimiting the
  # number with space helps do a string search for the line number.
  _Dbg_brkpt_file2linenos[$source_file]+=" $lineno "
  _Dbg_brkpt_file2brkpt[$source_file]+=" $_Dbg_brkpt_max "

  source_file=$(_Dbg_adjust_filename "$source_file")
  if (( $is_temp == 0 )) ; then 
    _Dbg_msg "Breakpoint $_Dbg_brkpt_max set in file ${source_file}, line $lineno."
  else 
    _Dbg_msg "One-time breakpoint $_Dbg_brkpt_max set in file ${source_file}, line $lineno."
  fi
  _Dbg_write_journal "_Dbg_brkpt_max=$_Dbg_brkpt_max"
}

# Internal routine to unset the actual breakpoint arrays
_Dbg_unset_brkpt_arrays() {
  typeset -i del=$1
  _Dbg_write_journal_eval "_Dbg_brkpt_line[$del]=''"
  _Dbg_write_journal_eval "_Dbg_brkpt_counts[$del]=''"
  _Dbg_write_journal_eval "_Dbg_brkpt_file[$del]=''"
  _Dbg_write_journal_eval "_Dbg_brkpt_enable[$del]=0"
  _Dbg_write_journal_eval "_Dbg_brkpt_cond[$del]=0"
  _Dbg_write_journal_eval "_Dbg_brkpt_onetime[$del]=''"
  ((_Dbg_brkpt_count--))
}

# Internal routine to delete a breakpoint by file/line.
_Dbg_unset_brkpt() {
  typeset -r  filename=$1
  typeset -ir line=$2
  typeset -r filevar="`_Dbg_file2var $filename`"
  typeset -r fullname="`_Dbg_expand_filename $filename`"
  typeset -i found=0
  
  ## typeset -r entries=`_Dbg_get_assoc_array_entry "_Dbg_brkpt_$filevar" $line`
  typeset -i del
  for del in $entries ; do 
    if [[ -z ${_Dbg_brkpt_file[$del]} ]] ; then
      _Dbg_msg "No breakpoint found at $filename:$line"
      continue
    fi
    typeset brkpt_fullname=$(_Dbg_expand_filename ${_Dbg_brkpt_file[$del]})
    if [[ $brkpt_fullname != $fullname ]] ; then 
      _Dbg_msg "Brkpt inconsistency:" \
	"$filename[$line] lists ${_Dbg_brkpt_file[$del]} at entry $del"
    else
      _Dbg_unset_brkpt_arrays $del
      ((found++))
      ((_Dbg_brkpt_count--))
    fi
  done
  _Dbg_write_journal_eval "unset _Dbg_brkpt_$filevar[$line]"
  return $found
}

# Routine to a delete breakpoint by entry number: $1.
# Returns whether or not anything was deleted.
_Dbg_delete_brkpt_entry() {
  (( $# == 0 )) && return 0
  typeset -r  del="$1"
  typeset -i  i
  typeset -i  found=0
  
  if [[ -z ${_Dbg_brkpt_file[$del]} ]] ; then
      _Dbg_errmsg "No breakpoint number $del."
      return 0
  fi
  typeset    source_file=${_Dbg_brkpt_file[$del]}
  typeset -i lineno=${_Dbg_brkpt_line[$del]}
  typeset -i try 
  typeset -a new_lineno_val; new_lineno_val=()
  typeset -a new_brkpt_nos; new_brkpt_nos=()
  typeset -i i=-1
  typeset -a brkpt_nos
  brkpt_nos=(${_Dbg_brkpt_file2brkpt[$source_file]})
  for try in ${_Dbg_brkpt_file2linenos[$source_file]} ; do 
      ((i++))
      if (( brkpt_nos[i] == del )) ; then
	  if (( try != $lineno )) ; then
	      _Dbg_errmsg 'internal brkpt structure inconsistency'
	      return 0
	  fi
	  _Dbg_unset_brkpt_arrays $del
	  ((found++))
      else
	  new_lineno_val+=$try
	  new_brkpt_nos+=${brkpt_nos[$i]}
      fi
  done
  set +x
  if (( found > 0 )) ; then
      if (( ${#new_lineno_val[@]} == 0 )) ; then 
	  _Dbg_write_journal_eval "unset '_Dbg_brkpt_file2linenos[$source_file]'"
	  _Dbg_write_journal_eval "unset '_Dbg_brkpt_file2brkpt[$source_file]'"
      else
	  _Dbg_write_journal_eval "_Dbg_brkpt_file2linenos[$source_file]=${new_lineno_val}"
	  _Dbg_write_journal_eval "_Dbg_brkpt_file2brkpt[$source_file]=${new_brkpt_nos}"
      fi
  fi

  return $found
}

# Enable/disable breakpoint(s) by entry numbers.
_Dbg_enable_disable_brkpt() {
  typeset -i on=$1
  typeset en_dis=$2
  typeset -i i=$3
  if [[ -n "${_Dbg_brkpt_file[$i]}" ]] ; then
    if [[ ${_Dbg_brkpt_enable[$i]} == $on ]] ; then
      _Dbg_errmsg "Breakpoint entry $i already $en_dis so nothing done."
    else
      _Dbg_write_journal_eval "_Dbg_brkpt_enable[$i]=$on"
      _Dbg_msg "Breakpoint entry $i $en_dis."
    fi
  else
    _Dbg_errmsg "Breakpoint entry $i doesn't exist so nothing done."
  fi
}
