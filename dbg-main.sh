# -*- shell-script -*-
zmodload -ap zsh/mapfile mapfile

# Things in init have to come before other includes and things in lib
# have to come before command.
source ${_Dbg_libdir}/init.inc

for file in ${_Dbg_libdir}/lib/*.sh ; do 
    source $file
done

for file in ${_Dbg_libdir}/command/*.sh ; do 
    source $file
done

unsetopt localtraps
set -o DEBUG_BEFORE_CMD

# Have we already specified  where to read debugger input from?
if [ -n "$o_cmdfile" ] ; then 
  _Dbg_input=($o_cmdfile)
  _Dbg_do_source ${_Dbg_input[1]}
  _Dbg_no_init=1
fi

if [[ -z $_Dbg_no_init && -r ~/.zshdbrc ]] ; then
  _Dbg_do_source ~/.zshbrc
fi

