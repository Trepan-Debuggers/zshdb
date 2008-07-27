# -*- shell-script -*-

#================ VARIABLE INITIALIZATIONS ====================#

# Where are we in stack? This can be changed by "up", "down" or "frame"
# commands. On debugger entry, the value is set to _Dbg_STACK_TOP.
typeset -i  _Dbg_stack_pos=1

#======================== FUNCTIONS  ============================#

# Print position $1 of stack frame (from global _Dbg_frame_stack)
# Prefix the entry with $2 if that's set.
function _Dbg_print_frame {
    local -i pos=${1:-$_Dbg_stack_pos}
    local file_line="${_Dbg_frame_stack[$pos]}"
    typeset prefix=${2:-''}

    _Dbg_split "$file_line" ':'
    typeset filename=${split_result[1]}
    typeset -i line=${split_result[2]}
    _Dbg_msg "$prefix$pos in file \`$filename' at line $line"

}
