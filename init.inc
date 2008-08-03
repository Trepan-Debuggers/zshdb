# -*- shell-script -*-
typeset -i _Dbg_running=1      # True we are not finished running the program

# zsh patterns matching doesn't work with variable names
# typeset -r int_pat='([0-9])##'
# typeset -r signed_int_pat='([-+]|)([0-9])##'
# typeset -r real_pat='([0-9])##.([0-9]|)'

typeset -i _Dbg_basename_only=0

# Equivalent to basename $_Dbg_orig_0 -- the short program name
typeset _Dbg_pname=${_Dbg_orig_0##*/} 

# Known normal IFS consisting of a space, tab and newline
typeset -r _Dbg_space_IFS=' 	
'

# $_Dbg_tmpdir could have been set by zshdb script rather than
# zsh --debugger
typeset _Dbg_tmpdir=/tmp

# Create temporary file based on $1
# file $1
_Dbg_tempname() {
  echo "$_Dbg_tmpdir/zshdb$1$$"
}
