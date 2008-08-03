# -*- shell-script -*-
# ==================== VARIABLES =======================================
# Are we inside the middle of a "skip" command?
typeset -i  _Dbg_inside_skip=0

typeset _Dbg_prompt_str='zshdb<1> '

# The canonical name of last command run.
typeset _Dbg_last_cmd=''

typeset -a _Dbg_debugger_commands

# Extract command names
for file in ${_Dbg_libdir}/command/*.cmd ; do 
    debugger_command=${file##*/}
    _Dbg_debugger_commands+=${debugger_command:s/.cmd//}
done


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
    expand_alias $1
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

	backtrace | T | where )
	  _Dbg_do_backtrace $@
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

	# next/single-step N times (default 1)
	n | ne | nex | next | s | st | ste | step | sk | ski | skip )
	  _Dbg_last_next_step_cmd="$_Dbg_cmd"
	  _Dbg_last_next_step_args="$args"
	  # _Dbg_do_next_step_skip $_Dbg_cmd "$args"
	  if [[ $_Dbg_cmd == sk* ]] ; then
	    _Dbg_inside_skip=1
	    _Dbg_last_cmd='skip'
	    return 1
	  else
	    _Dbg_last_cmd='next'
	    return 2
	  fi
	  ;;

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

# This is put at the so we have something at the end to stop at 
# when we debug this. By stopping at the end all of the above functions
# and variables can be tested.
[[ -z $_Dbg_processor_ver ]] && typeset -r _Dbg_processor_ver='$Id: dbg-processor.inc,v 1.3 2008/07/29 03:47:15 rockyb Exp $'
