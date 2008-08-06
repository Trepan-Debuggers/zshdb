# -*- shell-script -*-
zmodload -ap zsh/mapfile mapfile

# Things in init have to come before other includes and things in lib
# have to come before command.
source ${_Dbg_libdir}/init.inc

for file in ${_Dbg_libdir}/lib/*.inc ; do 
    source $file
done

for file in ${_Dbg_libdir}/command/*.cmd ; do 
    source $file
done

unsetopt localtraps
set -o DEBUG_BEFORE_CMD

