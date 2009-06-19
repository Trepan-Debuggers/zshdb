# -*- shell-script -*-
#   Copyright (C) 2008, 2009 Rocky Bernstein rocky@gnu.org
#
#   zshdb is free software; you can redistribute it and/or modify it under
#   the terms of the GNU General Public License as published by the Free
#   Software Foundation; either version 2, or (at your option) any later
#   version.
#
#   zshdb is distributed in the hope that it will be useful, but WITHOUT ANY
#   WARRANTY; without even the implied warranty of MERCHANTABILITY or
#   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#   for more details.
#   
#   You should have received a copy of the GNU General Public License along
#   with zshdb; see the file COPYING.  If not, write to the Free Software
#   Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA.

# Stuff common to zshdb and zshdb-trace. Include the rest of options
# processing. Also includes things which have to come before other includes
. ${_Dbg_libdir}/dbg-pre.sh

# All debugger lib code has to come before debugger command code.
typeset file
for file in ${_Dbg_libdir}/lib/*.sh ; do 
    source $file
done

for file in ${_Dbg_libdir}/command/*.sh ; do 
    source $file
done

unsetopt localtraps
set -o DEBUG_BEFORE_CMD

# Have we already specified where to read debugger input from?  
if [[ -n "$DBG_INPUT" ]] ; then 
  _Dbg_do_source "$DBG_INPUT"
  _Dbg_no_init=1
fi

# Run the user's debugger startup file
typeset _Dbg_startup_cmdfile=${HOME:-.}/.${_Dbg_debugger_name}rc
if [[ -z $_Dbg_o_nx && -r $_Dbg_startup_cmdfile ]] ; then
    _Dbg_do_source $_Dbg_startup_cmdfile
fi

# _Dbg_DEBUGGER_LEVEL is the number of times we are nested inside a debugger
# by virtue of running "debug" for example.
if [[ -z "${_Dbg_DEBUGGER_LEVEL}" ]] ; then
  typeset -ix _Dbg_DEBUGGER_LEVEL=1
fi

if ((Dbg_history_save)) ; then  
    history -ap "$_Dbg_histfile"
fi

if [[ -z "$_Dbg_tty" ]]; then 
    _Dbg_tty=$(tty)
    [[ $_Dbg_tty == 'not a tty' ]] && unset _Dbg_tty
fi
[[ -n "$_Dbg_tty" ]] && _Dbg_do_set inferior-tty $_Dbg_tty
