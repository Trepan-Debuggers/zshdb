# -*- shell-script -*-
_Dbg_libdir='.'
prefix=/usr/local  # cygwin gets PKGDATADIR wrong
[ -z $_Dbg_libdir ] && typeset _Dbg_libdir=${prefix}/share/zshdb

# Source everything in directory $3/$1.$2. If $3 is null, use $_Dbg_libdir
function source_directory {
  (($# != 3)) && return 1
  local lib=$1 ext=$2 dir=$3
  for file in ${_Dbg_libdir}/$lib/*$ext ; do 
    source $file
  done
}

typeset -a _Dbg_includes
_Dbg_includes=(init fns gdb processor stack sig)

for file in ${_Dbg_includes[@]} ; do 
  source ${_Dbg_libdir}/dbg-${file}.inc
done

source_directory 'lib' '.inc' $_Dbg_libdir 
source_directory 'command' '.cmd' $_Dbg_libdir 


