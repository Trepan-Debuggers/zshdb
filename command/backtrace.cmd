# -*- shell-script -*-
# Print a stack backtrace.  
# $1 is the maximum number of entries to include.

# This code assumes the version of zsh where functrace has file names
# and absolute line positions, not function names and offset.

_Dbg_do_backtrace() {

  if (( ! _Dbg_running )) ; then
      _Dbg_msg "No stack."
      return
  fi

  local prefix='##'
  local -i n=${#_Dbg_frame_stack}
  local -i count=${1:-$n}
  local -i i=1

  # Loop which dumps out stack trace.
  for (( i=1 ; (( i <= n && count > 0 )) ; i++ )) ; do 
    prefix='##'
    (( i == _Dbg_stack_pos)) && prefix='->'

    _Dbg_msg_nocr "$prefix$i "
    ((i!=1)) && _Dbg_msg_nocr "${_Dbg_func_stack[i-1]} called from "

    local file_line="${_Dbg_frame_stack[$i]}"
    _Dbg_split "$file_line" ':'
    typeset filename=${split_result[1]}
    typeset -i line=${split_result[2]}
    (( _Dbg_basename_only )) && filename=${filename##*/}
    _Dbg_msg "file \`$filename' at line ${line}"
    ((count++))
  done
  return 0
}
