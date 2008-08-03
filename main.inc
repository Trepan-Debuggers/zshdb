# -*- shell-script -*-
zmodload -ap zsh/mapfile mapfile

_Dbg_libdir='.'
prefix=/usr/local  # cygwin gets PKGDATADIR wrong
[ -z $_Dbg_libdir ] && typeset _Dbg_libdir=${prefix}/share/zshdb

# Things in init have to come before other includes and things in lib
# have to come before command.
source ${_Dbg_libdir}/init.inc

for file in ${_Dbg_libdir}/lib/*.inc ; do 
    source $file
done

typeset -a _Dbg_debugger_commands
for file in ${_Dbg_libdir}/command/*.cmd ; do 
    source $file
    # Extract command name
    debugger_command=${file##*/}
    _Dbg_debugger_commands+=${debugger_command:s/.cmd//}
done

unsetopt localtraps
set -o DEBUG_BEFORE_CMD

