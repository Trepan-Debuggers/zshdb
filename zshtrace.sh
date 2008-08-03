#!/usr/local/bin/zsh -f

typeset -a _Dbg_script_args
_Dbg_script_args=($@)

# Original $0. Note we can't set this in an include.
typeset -r _Dbg_orig_0=$0

. ./init.inc
. ./main.inc

# Note that this is called via zshdb rather than "zsh --debugger"
_Dbg_script=1

# Save me typing in testing.
if (( ${#_Dbg_script_args[@]} > 0 )) ; then
    _Dbg_script_file="$_Dbg_script_args[1]"
else
    _Dbg_script_file=./testing.sh
fi

# Set $1, $2 for source'd script.
set -- ${_Dbg_script_args[@]}
trap '_Dbg_debug_trap_handler $? "$@"' DEBUG
. $_Dbg_script_file
