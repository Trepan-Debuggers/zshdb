# -*- shell-script -*-
# dbg-opts.sh - zshdb command options processing. The bane of programming.
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

_Dbg_usage() {
  printf "Usage: 
   ${_Dbg_pname} [OPTIONS] <script_file>

Runs zsh <script_file> under a debugger.

options:
    -h | --help             Print this help.
    -q | --quiet            Do not print introductory and quiet messages.
    -A | --annotate  LEVEL  Set the annotation level.
    -B | --basename         Show basename only on source file listings. 
                            (Needed in regression tests)
    -L libdir | --library libdir
                            Set the directory location of library helper file: $_Dbg_main
    -n | --nx |--no-init    Don't run initialization files.
    -V | --version          Print the debugger version number.
    -x command | --command CMDFILE
                            Execute debugger commands from CMDFILE.
"
  exit 100
}

_Dbg_show_version() {
  printf 'There is absolutely no warranty for zshdb.  Type "show warranty" for details.
'
  exit 101
}

typeset -i _Dbg_annotate=0
typeset -i _Dbg_linetrace=0

# Debugger command file
typeset _Dbg_o_cmdfile='' _Dbg_o_nx='' _Dbg_o_basename='' _Dbg_o_quiet=''

local temp
zparseopts -D --                                       \
  A:=_Dbg_o_annotate  -annotate:=_Dbg_o_annotate       \
  B=_Dbg_o_basename   -basename=_Dbg_o_basename        \
  L:=temp             -library:=temp                   \
  V=_Dbg_o_version    -version=_Dbg_o_version          \
  h=_Dbg_o_help       -help=_Dbg_o_help                \
  n=_Dbg_o_nx         -nx=_Dbg_o_nx -no-init=_Dbg_o_nx \
  q=_Dbg_o_quiet      -quiet=_Dbg_o_quiet              \
  x:=_Dbg_o_cmdfile   -command:=_Dbg_o_cmdfile
                
[[ $? != 0 || "$_Dbg_o_help" != '' ]] && _Dbg_usage

if [[ -z $_Dbg_o_quiet || -n $_Dbg_o_version ]]; then 
  print "Zsh Shell Debugger, release $_Dbg_release"
  printf '
Copyright 2008 Rocky Bernstein
This is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.

'
fi
[[ -n "$_Dbg_o_version" ]] && _Dbg_show_version
[[ -n "$_Dbg_o_basename" ]] && _Dbg_basename_only=1
[[ -n "$_Dbg_o_cmdfile" ]] && {
    typeset -a _Dbg_input
    _Dbg_input=($_Dbg_o_cmdfile)
    DBG_INPUT=${_Dbg_input[-1]}
    unset _Dbg_input
}


# FIXME: check that _Dbg_o_annotate is an integer
if [[ -n $_Dbg_o_annotate ]] ; then
    typeset -a level; eval "level=($_Dbg_o_annotate)"
    if [[ ${level[-1]} == [0-9]* ]] ; then
	if (( ${level[-1]} > 3 || ${level[-1]} < 0)); then
	    print "Annotation level must be less between 0 and 3. Got: ${level[-1]}."
	else
	    _Dbg_annotate=${level[-1]}
	fi
    else
	print "Annotate option should be an integer, got ${level[-1]}."
    fi
fi
unset _Dbg_o_annotate _Dbg_o_version _Dbg_o_basename _Dbg_o_cmdfile
