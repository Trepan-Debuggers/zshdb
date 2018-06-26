# -*- shell-script -*-
# quit.sh - gdb-like "quit" debugger command
#
#   Copyright (C) 2008, 2010-2011, 2014, 2018 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add quit \
'**quit** [*exit-code* [*shell-levels*]]

Quit the debugger.

The program being debugged is aborted.  If *exit-code* is given, then
that will be the exit return code. If *shell-levels* is given, then up
to that many nested shells are quit. However to be effective, the last
of those shells should have been run under the debugger.

See also:
---------

**finish**, **return** and **run**.'

_Dbg_do_quit() {
    typeset -i return_code=${1:-$_Dbg_program_exit_code}

    typeset -i desired_quit_levels=${2:-0}

    if [[ $desired_quit_levels != [0-9]* ]] ; then
        _Dbg_errmsg "Argument ($desired_quit_levels) should be a number or nothing."
        return 0
    fi

    if (( desired_quit_levels == 0 \
        || desired_quit_levels > ZSH_SUBSHELL+1)) ; then
        ((desired_quit_levels=ZSH_SUBSHELL+1))
    fi

    ((_Dbg_QUIT_LEVELS+=desired_quit_levels))

    # Reduce the number of recorded levels that we need to leave by
    # if _Dbg_QUIT_LEVELS is greater than 0.
    ((_Dbg_QUIT_LEVELS--))

    ## write this to the next level up can read it.
    _Dbg_write_journal "_Dbg_QUIT_LEVELS=$_Dbg_QUIT_LEVELS"
    _Dbg_write_journal "_Dbg_step_ignore=$_Dbg_step_ignore"

    # Reset signal handlers to their default but only if
    # we are not in a subshell.
    if (( ZSH_SUBSHELL == 0 )) ; then

        # If we were told to restart from deep down, restart instead of quit.
        if [ -n "$_Dbg_RESTART_COMMAND" ] ; then
            _Dbg_erase_journals
            _Dbg_save_state
            exec $_Dbg_RESTART_COMMAND
        fi

        _Dbg_msg "${_Dbg_debugger_name}: That's all, folks..."
	# Get the last command into the history
	# set -o incappendhistory
	print -s -- $_Dbg_orig_cmd >/dev/null
        _Dbg_cleanup
    fi

    # And just when you thought we'd never get around to it...
    exit $return_code
}
_Dbg_alias_add q quit
_Dbg_alias_add q! quit
_Dbg_alias_add exit quit
