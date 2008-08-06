# -*- shell-script -*-
usage() {
  print "Usage: ${_Dbg_orig_0##*/} [-L | --library directory]"
  exit 100
}

local temp
zparseopts -D -- L:=temp -library:=temp -help=o_help h=o_help
[[ $? != 0 || "$o_help" != "" ]] && usage

