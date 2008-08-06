# -*- shell-script -*-
# Code common to zshdb and zshdb-trace.
# We assume _Dbg_libdir has been set correctly somehoaw

[[ -z $_Dbg_release ]] || return
typeset -r _Dbg_release='zshdb-0.01git'

_Dbg_libdir='.'
. ${_Dbg_libdir}/opts.inc

typeset -a _Dbg_script_args
_Dbg_script_args=($@)



