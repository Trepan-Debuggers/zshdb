# -*- shell-script -*-
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

# ==================== VARIABLES =======================================
# Are we inside the middle of a "skip" command?
typeset -i  _Dbg_inside_skip=0

typeset _Dbg_prompt_str="$_Dbg_debugger_name<1> "

# The canonical name of last command run.
typeset _Dbg_last_cmd=''

typeset -a _Dbg_debugger_commands

# ===================== FUNCTIONS =======================================

# Note: We have to be careful here in naming "local" variables. In contrast
# to other places in the debugger, because of the read/eval loop, they are
# in fact seen by those using the debugger. So in contrast to other "local"s
# in the debugger, we prefer to preface these with _Dbg_.
function _Dbg_process_commands {
    local _Dbg_prompt="$_Dbg_prompt_str"
    # _Dbg_preloop
    local _Dbg_cmd 
    local args
    while read "?$_Dbg_prompt" _Dbg_cmd args ; do
    	_Dbg_onecmd "$_Dbg_cmd" "$args"
	rc=$?
	# _Dbg_postcmd
        (( $rc != 0 )) && return $rc
    done
}

# Run a single command
# Parameters: _Dbg_cmd and args
# 
_Dbg_onecmd() {
    local expanded_alias; expand_alias $1
    local _Dbg_cmd="$expanded_alias"
    eval "set -- $2"

    case $_Dbg_cmd in
	# Comment line
	[#]* ) 
	  # _Dbg_remove_history_item
	  _Dbg_last_cmd="#"
	  ;;

	alias )
	  _Dbg_do_alias $@
	  ;;

	where )
	  _Dbg_do_backtrace $@
	  ;;

	# Continue
	c | cont | conti |contin |continu | continue )
	  
	  _Dbg_last_cmd='continue'
	  if _Dbg_do_continue $@ ; then
	    IFS="$_Dbg_old_IFS";
	    # _Dbg_write_journal_eval \
	    #  "_Dbg_old_set_opts=\"$_Dbg_old_set_opts -o functrace\""
	    return 1
	  fi
	  ;;

	# Move call stack down
	do | dow | down )
	  _Dbg_do_down $@
	  _Dbg_last_cmd='down'
	  ;;

	# evaluate as bash command
	e | ev | eva | eval )
	  _Dbg_do_eval $@
	  _Dbg_last_cmd='eval'
	  ;;

	#  Set stack frame
	fr | fra | fra | frame )
	  _Dbg_do_frame $@
	  _Dbg_last_cmd='frame'
	  ;;

	# print help command menu
	h | he | hel | help | '?'  )
	  _Dbg_do_help $args ;;

# 	# next/skip-step N times (default 1)
# 	n | ne | nex | next | sk | ski | skip )
# 	  _Dbg_last_next_step_cmd="$_Dbg_cmd"
# 	  _Dbg_last_next_step_args="$args"
# 	  # _Dbg_do_next_step_skip $_Dbg_cmd "$args"
# 	  if [[ $_Dbg_cmd == sk* ]] ; then
# 	    _Dbg_inside_skip=1
# 	    _Dbg_last_cmd='skip'
# 	    return 1
# 	  else
# 	    _Dbg_last_cmd='next'
# 	    return 2
# 	  fi
# 	  ;;

	# print globbed or substituted variables
	p | pr | pri | prin | print )
	  _Dbg_do_print "$args"
	  _Dbg_last_cmd='print'
	  ;;

	# quit
	q | qu | qui | quit )
	  _Dbg_last_cmd='quit'
	  _Dbg_do_quit $@
	  ;;

	# single-step N times (default 1)
	s | st | ste | step | n | ne | nex | next | sk | ski | skip )
	  _Dbg_last_next_step_cmd="$_Dbg_cmd"
	  _Dbg_last_next_step_args="$@"
	  _Dbg_do_step $@
	  return $?
	  ;;

	# restart debug session.
	ru | run )
	  _Dbg_last_cmd='run'
	  _Dbg_do_run $args
	  ;;

	# Move call stack up
	u | up )
	  _Dbg_do_up $args
	  _Dbg_last_cmd='up'
	  ;;

	* ) 
          _Dbg_msg "Undefined command: \"$_Dbg_cmd\". Try \"help\"." 
	  ;;
      esac
      return 0
}
