#!/bin/zsh
_Dbg_debug_trap_handler() {
    local -i _Dbg_lineno=$1
    shift
    local -i _Dbg_exitrc=$1
    shift
    local -a _Dbg_args
    for arg in $@ ; do 
	_Dbg_args+=$arg
    done
    set -a _Dbg_fs $funcstack
    shift _Dbg_fs
    echo "$_Dbg_fs $functrace $_Dbg_exitrc - $_Dbg_args"
}

zmodload -ap zsh/mapfile mapfile
if (( 0 != $# )) ; then
    file=$1
    shift
else
    file=./testing.sh
fi
trap '_Dbg_debug_trap_handler $LINENO $? $@' DEBUG
. $file "$@" # testing.
