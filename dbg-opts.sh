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

usage() {
  printf "Usage: 
   ${_Dbg_pname} [OPTIONS] <script_file>

Runs zsh <script_file> under a debugger.

options:
    -h | --help             print this help
    -q | --quiet            Do not print introductory and quiet messages.
    -A | --annotate  LEVEL  set annotation level.
    -B | --basename         basename only on source listings. 
                            (Needed in regression tests)
    -L libdir | --library libdir
                            set directory location of library helper file: $_Dbg_main
    -n | --nx |--no-init    Don't run initialization files
    -x command | --command cmdfile
                            execute debugger commands from cmdfile
"
  exit 100
}

show_version() {
  printf 'There is absolutely no warranty for zshdb.  Type "show warranty" for details.
'
  exit 101
}

typeset -i _Dbg_annotate=0

# Debugger command file
typeset o_cmdfile='' o_nx='' o_basename=''

local temp
zparseopts -D --                        \
  A:=o_annotate  -annotate:=o_annotate  \
  B=o_basename   -basename=o_basename   \
  L:=temp        -library:=temp         \
  V=o_version    -version=o_version     \
  h=o_help       -help=o_help           \
  n=o_nx         -nx=o_nx -no-init=o_nx \
  q=o_quiet      -quiet=o_quiet         \
  x:=o_cmdfile   -command:=o_cmdfile
                
[[ $? != 0 || "$o_help" != '' ]] && usage

if [[ -z $o_quiet || -n $o_version ]]; then 
  print "Zsh Shell Debugger, release $_Dbg_release"
  printf '
Copyright 2008 Rocky Bernstein
This is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.

'
fi
[[ -n $o_version ]] && show_version
[[ -n $o_basename ]] && _Dbg_basename_only=1

# FIXME: check that o_annotate is an integer
## [[ -n $o_annotate ]] && _Dbg_annotate=$o_annotate
