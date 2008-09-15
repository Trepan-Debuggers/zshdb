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

typeset -a _Dbg_yn
_Dbg_yn=("n" "y")         

# Return $2 copies of $1. If successful, $? is 0 and the return value
# is in result.  Otherwise $? is 1 and result ''
function _Dbg_copies { 
    result=''
    (( $# < 2 )) && return 1
    typeset -r string="$1"
    typeset -i count=$2 || return 2;
    (( count > 0 )) || return 3
    result=$(builtin printf "%${count}s" ' ')
    typeset cmd
    cmd="result=\${result// /$string}"
    eval $cmd
    return 0
}

_Dbg_defined() {
    (( 0 == $# )) && return 1
    output=$(typeset -p "$1" 2>&1)
    if [[ $? != 0 ]] ; then 
	return 1
    else
	return 0
    fi
}

# Add escapes to a string $1 so that when it is read back using
# eval echo "$1" it is the same as echo $1.
function _Dbg_esc_dq {
  builtin echo $1 | sed -e 's/[`$\"]/\\\0/g' 
}

# _Dbg_is_function returns 0 if $1 is a defined function or nonzero otherwise. 
# if $2 is nonzero, system functions, i.e. those whose name starts with
# an underscore (_), are included in the search.
_Dbg_is_function() {
    setopt ksharrays
    (( 0 == $# )) && return 1
    typeset needed_fn=$1
    typeset -i include_system=${2:-0}
    [[ ${needed_fn[0,0]} == '_' ]] && ((!include_system)) && {
	return 1
    }
    typeset fn
    fn=$(declare -f $needed_fn 2>&1)
    [[ -n "$fn" ]]
    return $?
}

# Set $? to $1 if supplied or the saved entry value of $?. 
function _Dbg_set_dol_q {
  [[ $# -eq 0 ]] && return $_Dbg_debugged_exit_code
  return $1
}

# Split string $1 into an array using delimitor $2 to split on
# The result is put in variable split_result
function _Dbg_split {
    local string="$1"
    local separator="$2"
    IFS="$separator" read -A split_result <<< $string
}

# Common routine for setup of commands that take a single
# linespec argument. We assume the following variables 
# which we store into:
#  filename, line_number, full_filename

function _Dbg_linespec_setup {
  typeset linespec=${1:-''}
  if [[ -z $linespec ]] ; then
    _Dbg_errmsg "Invalid line specification, null given"
  fi
  typeset -a word
  word=($(_Dbg_parse_linespec "$linespec"))
  if [[ ${#word[@]} == 0 ]] ; then
    _Dbg_msg "Invalid line specification: $linespec"
    return
  fi
  
  filename=${word[2]}
  typeset -ir is_function=${word[1]}
  line_number=${word[0]}
  full_filename=$filename
  full_filename=$(_Dbg_is_file $filename)

#   if (( is_function )) ; then
#       if [[ -z $full_filename ]] ; then 
# 	  _Dbg_readin "$filename"
# 	  full_filename=`_Dbg_is_file $filename`
#       fi
#   fi
}

# Parse linespec in $1 which should be one of
#   int
#   file:line
#   function-num
# Return triple (line,  is-function?, filename,)
# We return the filename last since that can have embedded blanks.
function _Dbg_parse_linespec {
  typeset linespec=$1
  case "$linespec" in

    # line number only - use .sh.file for filename
    [0-9]* )	
      typeset _Dbg_frame_filename=''
      _Dbg_frame_file $_Dbg_stack_pos 0
      echo "$linespec 0 ${_Dbg_frame_filename}"
      ;;
    
    # file:line
    [^:][^:]*[:][0-9]* )
      # Split the POSIX way
      typeset line_word=${linespec##*:}
      typeset file_word=${linespec%${line_word}}
      file_word=${file_word%?}
      echo "$line_word 0 $file_word"
      ;;

    # Function name or error
    * )
      if _Dbg_is_function $linespec ${_Dbg_debug_debugger} ; then 
	typeset -a word==( $(typeset -p +f $linespec) )
	typeset -r fn=${word[1]%\(\)}
	echo "${word[3]} 1 ${word[4]}"
      else
	echo ''
      fi
      ;;
   esac
}

# Add escapes to a string $1 so that when it is read back via "$1"
# it is the same as $1.
function _Dbg_onoff {
  typeset onoff='off.'
  (( $1 != 0 )) && onoff='on.'
  echo $onoff
}
