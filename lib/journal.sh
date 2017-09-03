# -*- shell-script -*-
# Things related to variable journaling.
#
#   Copyright (C) 2008, 2011, 2017 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

# We use a journal file to save variable state so that we can pass
# values set in a subshell or nested shell back. This typically
# includes debugger information, e.g. breakpoints and state. This file
# is just code (usually assignment statements) that get eval'd.

# The file to save the journal information.
typeset _Dbg_journal=$(_Dbg_tempname journal)

# append a command into journal file and then run the command.
_Dbg_write_journal_eval() {
    _Dbg_write_journal "$@"
    eval "$@"
}

# append a command into journal file and then run the command.
_Dbg_write_journal_var() {
    typeset var_name="$1"
    typeset val
    typeset val_cmd="$val=\${$var_name}"
    eval $val_cmd
    _Dbg_write_journal "${var_name}=${val}"
}

typeset -fuz is-at-least

_Dbg_write_journal_avar() {
    if (( ZSH_SUBSHELL != 0 )) ; then
	if is-at-least 5.4.1 ; then
	    typeset -p $1 >> ${_Dbg_journal} 2>/dev/null
	else
	    typeset -p $1 | grep -v ^typeset >> ${_Dbg_journal} 2>/dev/null
	fi
    fi
}

# Append a command into journal file. But we only need to do
# if we are in a subshell.
_Dbg_write_journal() {
  if (( ZSH_SUBSHELL != 0 )) ; then
    echo "$@" >> ${_Dbg_journal} 2>/dev/null
  fi
  return $?
}

# Remove all journal files.
_Dbg_erase_journals() {
    [[ -f $_Dbg_journal ]] && rm ${_Dbg_journal} 2>/dev/null
    return $?
}

# read in or "source" in journal file which will set variables.
_Dbg_source_journal() {

  if [ -r $_Dbg_journal ] ; then
    . $_Dbg_journal
    (( ZSH_SUBSHELL == 0 )) && _Dbg_erase_journals
  fi
}
