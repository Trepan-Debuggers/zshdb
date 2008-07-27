#!/bin/zsh

# Array of file:line string from functrace.
typeset -a _Dbg_frame_stack
typeset -a _Dbg_func_stack

function _Dbg_debug_trap_handler {
    typeset -i _Dbg_exitrc=$1
    shift
    # typeset -i _Dbg_lineno=$1
    # shift
    typeset -a _Dbg_args
    for arg in "$@" ; do 
	_Dbg_args+=$arg
    done
    _Dbg_frame_stack=($functrace)
    _Dbg_func_stack=($funcstack)
    _Dbg_print_location
    # _Dbg_process_commands
    # _Dbg_print_frame 1 '##'
    # echo "$_Dbg_frame_stack $_Dbg_exitrc - $_Dbg_args"
}

zmodload -ap zsh/mapfile mapfile

. ./dbg-main.inc

# Temporary crutch to save me typing.
if (( 0 != $# )) ; then
    file=$1
    shift
else
    file=./testing.sh
fi
# trap '_Dbg_debug_trap_handler $? $LINENO $@' DEBUG
trap '_Dbg_debug_trap_handler $? $@' DEBUG
. $file "$@" # testing.
