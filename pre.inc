[[ -z $_Dbg_release ]] || return
typeset -r _Dbg_release='zshdb-0.01git'

_Dbg_libdir='.'
prefix=/usr/local  # cygwin gets PKGDATADIR wrong
[ -z $_Dbg_libdir ] && typeset _Dbg_libdir=${prefix}/share/zshdb
# . ./opts

