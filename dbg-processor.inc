# -*- shell-script -*-
# ==================== VARIABLES =======================================
# Are we inside the middle of a "skip" command?
typeset -i  _Dbg_inside_skip=0

typeset _Dbg_prompt_str='bashdb<1> '

# The canonical name of last command run.
typeset _Dbg_last_cmd=''

for file in ${_Dbg_libdir}/command/*.cmd ; do 
  source $file
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
    local _Dbg_cmd="$1"
    shift
    local args="$@"
    case $_Dbg_cmd in
	# Comment line
	[#]* ) 
	  # _Dbg_remove_history_item
	  _Dbg_last_cmd="#"
	  ;;

	ba | bac | back | backt | backtr | backtra | backtrac | backtrace | bt | T | wh | whe | wher | where )
	  _Dbg_do_backtrace $args
	  ;;

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

	# quit
	q | qu | qui | quit )
	  _Dbg_last_cmd='quit'
	  _Dbg_do_quit $args
	  ;;
	* ) 
          _Dbg_msg "Undefined command: \"$_Dbg_cmd\". Try \"help\"." 
	  ;;
      esac
      return 0
}

