#!/src/external-cvs/zsh/Src/zsh -f

# Array of file:line string from functrace.
typeset -a _Dbg_frame_stack
typeset -a _Dbg_func_stack

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
set -o DEBUG_BEFORE_CMD
setopt localtraps
trap '_Dbg_debug_trap_handler $? "$@"' DEBUG
. $file $@
