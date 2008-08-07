# -*- shell-script -*-
usage() {
  printf "Usage: 
   ${_Dbg_orig_0##*/} [OPTIONS] <script_file>

Runs script_file under a debugger.

options:
    -h | --help             print this help
    -x command | --command cmdfile
                            execute debugger commands from cmdfile
    -L libdir | --library libdir
                            set directory location of library helper file: $_Dbg_main
"
  exit 100
}

# Debugger command file
local o_cmdfile=''

local temp
zparseopts -D -- L:=temp        -library:=temp \
                 h=o_help       -help=o_help \
                 x=o_cmdfile    -command=o_cmdfile
                
[[ $? != 0 || "$o_help" != '' ]] && usage

