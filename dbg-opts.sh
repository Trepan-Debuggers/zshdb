# -*- shell-script -*-
usage() {
  printf "Usage: 
   ${_Dbg_pname} [OPTIONS] <script_file>

Runs zsh <script_file> under a debugger.

options:
    -h | --help             print this help
    -q | --quiet            Do not print introductory and quiet messages.
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

# Debugger command file
local o_cmdfile='' o_nx='' o_basename=''

local temp
zparseopts -D --                        \
  B=o_basename                          \
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
