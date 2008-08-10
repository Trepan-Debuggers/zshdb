# -*- shell-script -*-
# Print location in gdb-style format: file:line
# So happens this is how it's stored in global _Dbg_frame_stack which
# is where we get the information from
function _Dbg_print_location {
    typeset -i pos=${1:-$_Dbg_stack_pos}
    typeset file_line="${_Dbg_frame_stack[$pos]}"

    _Dbg_split "$file_line" ':'

    typeset filename=${split_result[1]}
    typeset -i line=${split_result[2]}
    if ((_Dbg_basename_only)); then
	filename=${filename##*/}
	file_line="${filename}:${line}"
    fi
    ((pos1=1))
    if [[ $filename == $_Dbg_func_stack[pos1] ]] ; then
	_Dbg_msg "($file_line): -- nope"
    else
	_Dbg_msg "($file_line):"
    fi
}
