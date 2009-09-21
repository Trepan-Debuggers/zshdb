# -*- shell-script -*-
# fns.sh - Debugger Utility Functions
#
#   Copyright (C) 2008, 2009 Rocky Bernstein rocky@gnu.org
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
  builtin printf "%q\n" "$1"
}

# _Dbg_get_typeset_attr echoes a list of all of the functions matching
# optional pattern if $1 is nonzero, include debugger functions,
# i.e. those whose name starts with an underscore (_Dbg), are included in
# the search.  
# A grep pattern can be specified to filter function names. If the 
# pattern starts with ! we report patterns that don't match.
_Dbg_get_typeset_attr() {
    (( $# == 0 )) && return 1
    typeset attr="$1"; shift
    typeset pat=''
    (( $# > 0 )) && { pat=$1 ; shift; }
    (( $# != 0 )) && return 1

    typeset cmd="typeset $attr"
    if [[ -n $pat ]] ; then
	if [[ ${pat[0]} == '!' ]] ; then
	    cmd+=" | grep -v ${pat[1,-1]}"
	else
	    cmd+=" | grep $pat"
	fi
    fi
    ((!_Dbg_debug_debugger)) && cmd+=' | grep -v ^_Dbg_'
    eval $cmd
}

# _Dbg_is_function returns 0 if $1 is a function or nonzero otherwise. 
# if $2 is nonzero, system functions, i.e. those whose name starts with
# an underscore (_), are included in the search.
_Dbg_is_function() {
    # setopt ksharrays  # Done in _Dbg_debug_trap_handler
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

# _Dbg_is_alias returns 0 if $1 is an alias or nonzero otherwise. 
_Dbg_is_alias() {
    # setopt ksharrays  # Done in _Dbg_debug_trap_handler
    (( 0 == $# )) && return 1
    typeset needed_alias=$1
    typeset al
    al=$(alias $needed_alias 2>&1)
    return $?
}

# Print "on" or "off" depending on whether $1 is true (0) or false
# (nonzero).
function _Dbg_onoff {
  typeset onoff='off.'
  (( $1 != 0 )) && onoff='on.'
  echo $onoff
}

# Set $? to $1 if supplied or the saved entry value of $?. 
function _Dbg_set_dol_q {
  (( $# == 0 )) && return $_Dbg_debugged_exit_code
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
    (($# != 1)) && return 2
    typeset linespec=$1
    typeset -a word
    # FIXME when we have a filename with embedded blanks, we got trouble
    # because tokenization will split this into more tokens.
    # Possibly the right fix is to return via a dynamic variable.
    _Dbg_parse_linespec "$linespec"
    if [[ ${#word[@]} == 0 ]] ; then
	_Dbg_errmsg "Invalid line specification: $linespec"
	return 1
    fi
    
    filename=${word[2]}
    typeset -i is_function=${word[1]}
    line_number=${word[0]}
    full_filename=$filename
    full_filename=$(_Dbg_is_file "$filename")

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
# Return triple (line,  is-function?, filename,) stored in array
# "word" which the caller should have declared.
# We return the filename last since that can have embedded blanks.
function _Dbg_parse_linespec {
  typeset linespec="$1"
  case "$linespec" in

    # line number only - use filename from last adjust_frame
    [0-9]* )	
	  word=($linespec 0 "${_Dbg_frame_last_filename}")
	  return 0
	  ;;
    
    # file:line
    [^:][^:]*[:][0-9]* )
      # Split the POSIX way
      typeset line_word=${linespec##*:}
      typeset file_word=${linespec%${line_word}}
      file_word=${file_word%?}
      word=("$line_word" 0 "$file_word")
      return 0
      ;;

    # Function name or error
    * )
      if _Dbg_is_function $linespec ${_Dbg_debug_debugger} ; then 
	typeset -a word==( $(typeset -p +f $linespec) )
	typeset -r fn=${word[1]%\(\)}
	word=(${word[3]} 1 "${word[4]}")
	return 0
      fi
      ;;
   esac
  return 1
}
