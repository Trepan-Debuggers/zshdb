# -*- shell-script -*-
_Dbg_libdir='.'
prefix=/usr/local  # cygwin gets PKGDATADIR wrong
[ -z $_Dbg_libdir ] && typeset _Dbg_libdir=${prefix}/share/zshdb

typeset -a _Dbg_includes
_Dbg_includes=(init fns gdb processor stack sig)

for file in ${_Dbg_includes[@]} ; do 
  source ${_Dbg_libdir}/dbg-${file}.inc
done
