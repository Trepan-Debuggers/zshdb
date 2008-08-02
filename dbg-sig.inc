# -*- shell-script -*-
# dbg-sig.inc - Bourne Again Shell Debugger Utility Functions
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
function _Dbg_debug_trap_handler {
    trap 'echo EXIT encountered inside debugger' EXIT
    typeset -i _Dbg_debugged_exit_code=$1
    shift
    typeset -a _Dbg_args
    _Dbg_args=("$@")

    # Determine if we stop or not. 

    # If we don't have to stop we might consider skipping 
    _Dbg_set_debugger_entry
    _Dbg_frame_stack=($functrace)
    _Dbg_func_stack=($funcstack)

    shift _Dbg_func_stack # Remove our function name

    _Dbg_print_location
    _Dbg_process_commands
    # _Dbg_print_frame 1 '##'
    # echo "$_Dbg_frame_stack $_Dbg_debugged_exit_code - $_Dbg_args"
}

# Cleanup routine: erase temp files before exiting.
_Dbg_cleanup() {
  rm $_Dbg_evalfile 2>/dev/null
  # _Dbg_erase_journals
  # _Dbg_restore_user_vars
}

# Somehow we can't put this in _Dbg_cleanup and have it work.
# I am not sure why.
_Dbg_cleanup2() {
  # _Dbg_erase_journals
  trap - EXIT
}
