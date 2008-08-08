# -*- shell-script -*-
# dbg-pre.sh - Code common to zshdb and zshdb-trace that has to run first
#
#   Copyright (C) 2008 Rocky Bernstein rocky@gnu.org
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

[[ -z $_Dbg_release ]] || return
typeset -r _Dbg_release='0.01git'

# Name we refer to ourselves by
typeset _Dbg_debugger_name='zshdb'

# Will be set to 1 if called via zshdb rather than "zsh --debugger"
typeset -i _Dbg_script=0

typeset -i _Dbg_basename_only=0

# $_Dbg_tmpdir could have been set by zshdb script rather than
# zsh --debugger
typeset _Dbg_tmpdir=/tmp

# Create temporary file based on $1
# file $1
_Dbg_tempname() {
  echo "$_Dbg_tmpdir/${_Dbg_debugger_name}$1$$"
}

# Code common to zshdb and zshdb-trace.
# We assume _Dbg_libdir has been set correctly somehoaw

# Process command-line options
. ${_Dbg_libdir}/dbg-opts.sh

# Save the initial working directory so we can reset it on a restart.
typeset _Dbg_init_cwd=$PWD

# typeset -i _Dbg_have_set0=0
# if [[ -r $_Dbg_libdir/builtin/set0 ]] ; then
#   if enable -f $_Dbg_libdir/builtin/set0  set0 >/dev/null 2>&1 ; then
#     _Dbg_have_set0=1
#   fi
# fi

typeset -a _Dbg_script_args
_Dbg_script_args=($@)

typeset -i _Dbg_running=1      # True we are not finished running the program

# Known normal IFS consisting of a space, tab and newline
typeset _Dbg_space_IFS=' 	
'

# Number of statements to run before entering the debugger.
# Is used intially to get out of sourced dbg-main.inc script
# and in zshdb script to not stop in remaining zshdb statements
# before the sourcing the script to be debugged.
typeset -i _Dbg_step_ignore=1

# Array of file:line string from functrace.
typeset -a _Dbg_frame_stack
typeset -a _Dbg_func_stack

