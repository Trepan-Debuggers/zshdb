function _Dbg_debug_trap_handler {
    typeset -i _Dbg_exitrc=$1
    shift
    # typeset -i _Dbg_lineno=$1
    # shift
    typeset -a _Dbg_args
    for arg in "$@" ; do 
	_Dbg_args+=$arg
    done

    # Determine if we stop or not. 

    # If we don't have to stop we might consider skipping 
    _Dbg_frame_stack=($functrace)
    _Dbg_func_stack=($funcstack)

    shift _Dbg_func_stack # Remove our function name

    _Dbg_print_location
    _Dbg_process_commands
    # _Dbg_print_frame 1 '##'
    # echo "$_Dbg_frame_stack $_Dbg_exitrc - $_Dbg_args"
}

