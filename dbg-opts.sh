# -*- shell-script -*-
usage() {
  printf "Usage: 
   ${_Dbg_orig_0##*/} [OPTIONS] <script_file>

Runs zsh <script_file> under a debugger.

options:
    -h | --help             print this help
    -x command | --command cmdfile
                            execute debugger commands from cmdfile
    -L libdir | --library libdir
                            set directory location of library helper file: $_Dbg_main
    -q | --quiet            Do not print introductory and quiet messages.
"
  exit 100
}

# Debugger command file
local o_cmdfile=''

local temp
zparseopts -D -- L:=temp        -library:=temp \
                 h=o_help       -help=o_help \
                 q=o_quiet      -quiet=o_quiet \
                 x=o_cmdfile    -command=o_cmdfile
                
[[ $? != 0 || "$o_help" != '' ]] && usage

if [[ -z $o_quiet ]] ; then 
  echo "Zsh Shell Debugger, release $_Dbg_release"
  printf '
Copyright 2008 Rocky Bernstein
This is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.

'
fi


