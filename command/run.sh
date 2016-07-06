# -*- shell-script -*-
# run command.
#
#   Copyright (C) 2008-2010, 2016 Rocky Bernstein rocky@gnu.org
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

# Restart script in same way with saved arguments (probably the same
# ones as we were given before).

_Dbg_help_add run \
'**run** [*args*]

Attempt to restart the program.

See also:
---------

**set args**, **kill** and **quit**'

_Dbg_do_run() {

  typeset script_args
  typeset exec_cmd
  if (( $# == 0 )) ; then
      script_args=${_Dbg_script_args[@]}
      typeset SH_RUN_CMDLINE; _Dbg_run_cmdline
      if [[ -n $SH_RUN_CMDLINE ]] ; then
          exec_cmd="$SH_RUN_CMDLINE";
      else
          exec_cmd="$_Dbg_script_file"
          [[ -n $script_args ]] && exec_cmd+=" $script_args"
      fi
  else
      exec_cmd="$_Dbg_script_file"
      script_args=$@
      [[ -n $script_args ]] && exec_cmd+=" $script_args"
  fi

  if (( !_Dbg_script )); then
#     if [[ $_cur_source_file == $_Dbg_bogus_file ]] ; then
#       script_args="--debugger -c \"$SH_EXECUTION_STRING\""
#       exec_cmd="$SH_RUN_CMDLINE --debugger -c \"$SH_EXECUTION_STRING\"";
#     else
#       exec_cmd="$SH_RUN_CMDLINE --debugger $_Dbg_orig_0 $script_args";
#     fi
      :
  fi

  if (( _Dbg_set_basename )) ; then
    _Dbg_msg "Restarting with: $script_args"
  else
    _Dbg_msg "Restarting with: $exec_cmd"
  fi

  # If we are in a subshell we need to get out of those levels
  # first before we restart. The strategy is to write into persistent
  # storage the restart command, and issue a "quit." The quit should
  # discover the restart at the last minute and issue the restart.
  if (( ZSH_SUBSHELL > 0 )) ; then
    _Dbg_msg "Note you are in a subshell. We will need to leave that first."
    _Dbg_write_journal "_Dbg_RESTART_COMMAND=\"$exec_cmd\""
    _Dbg_do_quit 0
  fi
  _Dbg_save_state

  builtin cd $_Dbg_init_cwd

  _Dbg_cleanup
  eval "exec $exec_cmd"
}

_Dbg_alias_add R run
_Dbg_alias_add restart run
