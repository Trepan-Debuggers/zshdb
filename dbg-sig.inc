function _Dbg_debug_trap_handler {
    typeset -i _Dbg_debugged_exit_code=$1
    shift
    # typeset -i _Dbg_lineno=$1
    # shift
    typeset -a _Dbg_args
    for arg in "$@" ; do 
	_Dbg_args+=$arg
    done

    # Determine if we stop or not. 

    # If we don't have to stop we might consider skipping 
    _Dbg_set_debugger_entry
    _Dbg_frame_stack=($functrace)
    _Dbg_func_stack=($funcstack)

    shift _Dbg_func_stack # Remove our function name

    _Dbg_print_location
    _Dbg_process_commands
    # _Dbg_print_frame 1 '##'
    # echo "$_Dbg_frame_stack $_Dbg_debugged_exit_code - $_Dbg_args"
}

# Cleanup routine: erase temp files before exiting.
_Dbg_cleanup() {
  rm $_Dbg_evalfile 2>/dev/null
  # _Dbg_erase_journals
  # _Dbg_restore_user_vars
}

# Somehow we can't put this in _Dbg_cleanup and have it work.
# I am not sure why.
_Dbg_cleanup2() {
  # _Dbg_erase_journals
  trap - EXIT
}
