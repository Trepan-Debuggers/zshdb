# -*- shell-script -*-
# break.sh - Debugger Break and Watch routines
#
#   Copyright (C) 2008-2009, 2011, 2014, 2016-2017 Rocky Bernstein
#   <rocky@gnu.org>
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

# Maps a resolved filename to a list of beakpoint line numbers in that file
typeset -A _Dbg_brkpt_file2linenos; _Dbg_brkpt_file2linenos=()

# Maps a resolved filename to a list of breakpoint entries.
typeset -A _Dbg_brkpt_file2brkpt; _Dbg_brkpt_file2brkpt=()

# Note: we loop over possibly sparse arrays with _Dbg_brkpt_max by adding one
# and testing for an entry. Could add yet another array to list only
# used indices. Zsh is kind of primitive.

#========================= FUNCTIONS   ============================#

function _Dbg_save_breakpoints {
  typeset -p _Dbg_brkpt_line         >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_file         >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_cond         >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_counts       >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_enable       >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_onetime      >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_max          >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_file2linenos >> $_Dbg_statefile
  typeset -p _Dbg_brkpt_file2brkpt   >> $_Dbg_statefile

}

_Dbg_breakpoint_list() {
    typeset -i i
    list=''
    for ((i=0; i<=${#_Dbg_brkpt_file[@]}; i++)) ; do
	[[ -n ${_Dbg_brkpt_file[i]} ]] && list="${list}${i} "
    done
    echo $list
}


# Start out with general break/watchpoint functions first...

# Enable/disable breakpoint or watchpoint by entry numbers.
_Dbg_enable_disable() {
  if (($# == 0)) ; then
    _Dbg_errmsg 'Expecting a list of breakpoint/watchpoint numbers. Got none.'
    return 1
  fi
  typeset -i on=$1
  typeset en_dis=$2
  shift; shift

  if [[ $1 == 'display' ]] ; then
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
  elif [[ $1 == 'action' ]] ; then
    shift
    to_go="$@"
    typeset i
    for i in $to_go ; do
      if [[ $i == [0-9]* ]] ; then
	  _Dbg_enable_disable_action $on $en_dis $i
      else
	  _Dbg_errmsg "Invalid entry number skipped: $i"
      fi
    done
    return 0
  elif [[ $1 == 'breakpoints' ]] ; then
    shift
    to_go="$@"
    if (( 0 == $# )) ; then
	to_go=$(_Dbg_breakpoint_list)
    fi
  else
    to_go="$@"
    if (( 0 == $# )) ; then
	to_go=$(_Dbg_breakpoint_list)
    fi
  fi

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

# Print a message regarding how many times we've encountered
# breakpoint number $1 if the number of times is greater than 0.
# Uses global array _Dbg_brkpt_counts.
function _Dbg_print_brkpt_count {
  typeset -i i; i=$1
  if (( _Dbg_brkpt_counts[i] != 0 )) ; then
    if (( _Dbg_brkpt_counts[i] == 1 )) ; then
      _Dbg_printf '    breakpoint already hit 1 time'
    else
      _Dbg_printf "    breakpoint already hit %d times" ${_Dbg_brkpt_counts[$i]}
    fi
  fi
}

#======================== BREAKPOINTS  ============================#

# clear all brkpts
function _Dbg_clear_all_brkpt {
  _Dbg_write_journal_eval "_Dbg_brkpt_file2linenos=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_file2brkpt=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_line=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_cond=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_file=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_enable=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_counts=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_onetime=()"
  _Dbg_write_journal_eval "_Dbg_brkpt_count=0"
}

# Internal routine to a set breakpoint unconditonally.

_Dbg_set_brkpt() {
    (( $# < 3 || $# > 4 )) && return 1
    typeset source_file
    source_file=$(_Dbg_expand_filename "$1")
    $(_Dbg_is_int "$2") || return 1
    typeset -ri lineno=$2
    typeset -ri is_temp=$3
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

    typeset dq_source_file
    dq_source_file=$(_Dbg_esc_dq "$source_file")
    typeset dq_condition=$(_Dbg_esc_dq "$condition")
    _Dbg_write_journal "_Dbg_brkpt_line[$_Dbg_brkpt_max]=$lineno"
    _Dbg_write_journal "_Dbg_brkpt_file[$_Dbg_brkpt_max]=\"$dq_source_file\""
    _Dbg_write_journal "_Dbg_brkpt_cond[$_Dbg_brkpt_max]=\"$dq_condition\""
    _Dbg_write_journal "_Dbg_brkpt_onetime[$_Dbg_brkpt_max]=$is_temp"
    _Dbg_write_journal "_Dbg_brkpt_counts[$_Dbg_brkpt_max]=0"
    _Dbg_write_journal "_Dbg_brkpt_enable[$_Dbg_brkpt_max]=1"
    _Dbg_write_journal "_Dbg_brkpt_count=${_Dbg_brkpt_count}"

    # Add line number with a leading and trailing space. Delimiting the
    # number with space helps do a string search for the line number.

    # Note in the below two lines we don't eval.
    # That is done as a separate _Dbg_write_journal_avar
    _Dbg_brkpt_file2linenos[$source_file]+=" $lineno "
    _Dbg_brkpt_file2brkpt[$source_file]+=" $_Dbg_brkpt_max "

    _Dbg_write_journal_avar _Dbg_brkpt_file2linenos
    _Dbg_write_journal_avar _Dbg_brkpt_file2brkpt

    source_file=$(_Dbg_adjust_filename "$source_file")
    if (( is_temp == 0 )) ; then
	_Dbg_msg "Breakpoint $_Dbg_brkpt_max set in file ${source_file}, line $lineno."
    else
	_Dbg_msg "One-time breakpoint $_Dbg_brkpt_max set in file ${source_file}, line $lineno."
    fi
    _Dbg_write_journal "_Dbg_brkpt_max=$_Dbg_brkpt_max"
    return 0
}

# Internal routine to unset the actual breakpoint arrays.
# 0 is returned if successful
function _Dbg_unset_brkpt_arrays {
    (( $# != 1 )) && return 1
    typeset -i del=$1
    _Dbg_write_journal_eval "_Dbg_brkpt_line[$del]=''"
    _Dbg_write_journal_eval "_Dbg_brkpt_counts[$del]=''"
    _Dbg_write_journal_eval "_Dbg_brkpt_file[$del]=''"
    _Dbg_write_journal_eval "_Dbg_brkpt_enable[$del]=0"
    _Dbg_write_journal_eval "_Dbg_brkpt_cond[$del]=0"
    _Dbg_write_journal_eval "_Dbg_brkpt_onetime[$del]=''"
    ((_Dbg_brkpt_count--))
    return 0
}

# Internal routine to delete a breakpoint by file/line.
# The number of breakpoints (0 or 1) is returned.
function _Dbg_unset_brkpt {
    (( $# == 2 )) || return 0
    typeset -r filename="$1"
    $(_Dbg_is_int "$2") || return 0
    typeset -i lineno=$2
    typeset    fullname
    fullname=$(_Dbg_expand_filename "$filename")

    # FIXME: combine with _Dbg_hook_breakpoint_hit
    typeset -a linenos
    eval "linenos=(${_Dbg_brkpt_file2linenos[$fullname]})"
    typeset -a brkpt_nos
    eval "brkpt_nos=(${_Dbg_brkpt_file2brkpt[$fullname]})"

    typeset -i i
    for ((i=0; i < ${#linenos[@]}; i++)); do
	if (( linenos[i] == lineno )) ; then
	    # Got a match, find breakpoint entry number
	    typeset -i brkpt_num
	    (( brkpt_num = brkpt_nos[i] ))
	    _Dbg_unset_brkpt_arrays $brkpt_num
	    linenos[i]=()  # This is the zsh way to unset an array element
	    _Dbg_brkpt_file2linenos[$fullname]=${linenos[@]}
	    typeset -a brkpt_nos
	    eval "brkpt_nos=(${_Dbg_brkpt_file2brkpt[$filename]})"
	    brkpt_nos[i]=()
	    _Dbg_brkpt_file2brkpt[$filename]=${brkpt_nos[@]}
	    return 1
	fi
    done
    _Dbg_msg "No breakpoint found at $filename:$lineno"
    return 0
}

# Routine to a delete breakpoint by entry number: $1.
# Returns whether or not anything was deleted.
function _Dbg_delete_brkpt_entry {
    (( $# == 0 )) && return 0
    typeset -r  del="$1"
    typeset -i  i
    typeset -i  found=0

    if [[ -z ${_Dbg_brkpt_file[$del]} ]] ; then
	_Dbg_errmsg "No breakpoint number $del."
	return 1
    fi
    typeset    source_file=${_Dbg_brkpt_file[$del]}
    typeset -i lineno=${_Dbg_brkpt_line[$del]}
    typeset -i try
    typeset new_lineno_val
    typeset new_brkpt_nos
    typeset -i i=-1
    typeset -a brkpt_nos
    brkpt_nos=(${_Dbg_brkpt_file2brkpt[$source_file]})
    for try in ${_Dbg_brkpt_file2linenos[$source_file]} ; do
	((i++))
	if (( brkpt_nos[i] == del )) ; then
	    if (( try != lineno )) ; then
		_Dbg_errmsg 'internal brkpt structure inconsistency'
		return 1
	    fi
	    _Dbg_unset_brkpt_arrays $del
	    ((found++))
	else
	    new_lineno_val+=" $try"
	    new_brkpt_nos+=" ${brkpt_nos[$i]}"
	fi
    done
    if (( found > 0 )) ; then
	if (( ${#new_lineno_val[@]} == 0 )) ; then
	    _Dbg_write_journal_eval "unset '_Dbg_brkpt_file2linenos[$source_file]'"
	    _Dbg_write_journal_eval "unset '_Dbg_brkpt_file2brkpt[$source_file]'"
	else
	    _Dbg_write_journal_eval "_Dbg_brkpt_file2linenos[$source_file]=\"${new_lineno_val}\""
	    _Dbg_write_journal_eval "_Dbg_brkpt_file2brkpt[$source_file]=\"${new_brkpt_nos}\""
	fi
	return 0
    fi

    return 1
}

# Enable/disable breakpoint(s) by entry numbers.
function _Dbg_enable_disable_brkpt {
    (($# < 2)) && return 1
    typeset -i on=$1
    typeset en_dis=$2
    typeset -a brkpts=($3)
    typeset -i rc=0

    for i in "${brkpts[@]}";  do
	if [[ -n "${_Dbg_brkpt_file[$i]}" ]] ; then
	    if [[ ${_Dbg_brkpt_enable[$i]} == $on ]] ; then
		_Dbg_errmsg "Breakpoint entry $i already ${en_dis}, so nothing done."
		rc=1
	    else
		_Dbg_write_journal_eval "_Dbg_brkpt_enable[$i]=$on"
		_Dbg_msg "Breakpoint entry $i $en_dis."
	    fi
	else
	    _Dbg_errmsg "Breakpoint entry $i doesn't exist, so nothing done."
	    rc=1
	fi
    done
    return $rc

}

# # Enable/disable breakpoint(s) by entry numbers.
# function _Dbg_enable_disable_brkpt {
#     (($# < 2)) && return 1
#     typeset -i on=$1
#     typeset en_dis=$2
#     typeset -a brkpts=($3)
#     typeset -i rc=0

#     # FIXME: The below is bash for getting array index values. Not sure what
#     # the equivalent for zsh is.

#     # if (( 0 == ${#brkpts[@]} )) ; then
#     # 	brkpts=${!brkpts[@]}
#     # fi

#     # for (( i = 1; i <= $#brkpts; i++ )) do
#     # 	if [[ -n "${_Dbg_brkpt_file[$i]}" ]] ; then
#     # 	    if [[ ${_Dbg_brkpt_enable[$i]} == $on ]] ; then
#     # 		_Dbg_errmsg "Breakpoint entry $i already ${en_dis}, so nothing done."
#     # 		rc=1
#     # 	    else
#     # 		_Dbg_write_journal_eval "_Dbg_brkpt_enable[$i]=$on"
#     # 		_Dbg_msg "Breakpoint entry $i $en_dis."
#     # 	    fi
#     # 	else
#     # 	    _Dbg_errmsg "Breakpoint entry $i doesn't exist, so nothing done."
#     # 	    rc=1
#     # 	fi
#     # done
#     return $rc

# }
