#!/usr/local/bin/zsh -f

typeset -a _Dbg_script_args
_Dbg_script_args=($@)

# Original $0. Note we can't set this in an include.
typeset -r _Dbg_orig_0=$0

# Stuff common to zshdb and zshdb-trace
. ./pre.inc

# Things that have to be done before the bulk of main
. ./main.inc

# Note that this is called via zshdb rather than "zsh --debugger" or zshdb-trace
_Dbg_script=1

# Save me typing in testing.
if (( ${#_Dbg_script_args[@]} > 0 )) ; then
    _Dbg_script_file="$_Dbg_script_args[1]"
    shift _Dbg_script_args
else
    _Dbg_script_file=./testing.sh
fi

while : ; do
  _Dbg_step_ignore=2
  trap '_Dbg_debug_trap_handler $? "$@"' DEBUG
  . $_Dbg_script_file ${_Dbg_script_args[@]}
  trap '' DEBUG
  _Dbg_msg "Program terminated. Type 's' or 'R' to restart."
  _Dbg_process_commands
done
