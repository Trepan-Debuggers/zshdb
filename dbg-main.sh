# -*- shell-script -*-
zmodload -ap zsh/mapfile mapfile

# Stuff common to zshdb and zshdb-trace. Include the rest of options
# processing. Also includes things which have to come before other includes
. ${_Dbg_libdir}/dbg-pre.sh

# All debugger lib code has to come before debugger command code.
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

# Run the user's debugger startup file
if [[ -z $o_nx && -r ~/.zshdbrc ]] ; then
  _Dbg_do_source ~/.zshbrc
fi

