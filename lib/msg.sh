# -*- shell-script -*-
#   Copyright (C) 2008, 2009 Rocky Bernstein rocky@gnu.org
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

# Called when a dangerous action is about to be done to make sure it's
# okay. `prompt' is printed, and "yes", or "no" is solicited.  The
# user response is returned in variable $_Dbg_response and $? is set
# to 0.  _Dbg_response is set to 'error' and $? set to 1 on an error.
# 
_Dbg_confirm() {
    if (( $# < 1 || $# > 2 )) ; then
	_Dbg_response='error'
	return 0
    fi
    _Dbg_confirm_prompt=$1
    typeset _Dbg_confirm_default=${2:-'no'}
    while : ; do 
	  if [[ -t $_Dbg_fdi ]]; then
	      vared -e -h -p "$_Dbg_confirm_prompt" _Dbg_response <&${_Dbg_fdi} || break
	  else
	      read "?$_Dbg_confirm_prompt" _Dbg_response <&${_Dbg_fdi} || break
	  fi

	case "$_Dbg_response" in
	    'y' | 'yes' | 'yeah' | 'ya' | 'ja' | 'si' | 'oui' | 'ok' | 'okay' )
		_Dbg_response='y'
		return 0
		;;
	    'n' | 'no' | 'nope' | 'nyet' | 'nein' | 'non' )
		_Dbg_response='n'
		return 0
		;;
	    *)
		if [[ $_Dbg_response =~ '^[ \t]*$' ]] ; then
		    set +x
		    return 0
		else
		    _Dbg_msg "I don't understand \"$_Dbg_response\"."
		    _Dbg_msg "Please try again entering 'yes' or 'no'."
		    _Dbg_response=''
		fi
		;;
	esac

    done
}

# Add escapes to a string $1 so that when it is read back using
# eval echo "$1" it is the same as echo $1.
function _Dbg_errmsg {
    typeset -r prefix='**'
    _Dbg_msg "$prefix $@"
}

# Print an error message without the ending carriage return
function _Dbg_errmsg_no_cr {
    typeset -r prefix='**'
    _Dbg_msg_nocr "$prefix $@"
}

function _Dbg_msg {
    if [[ -n $_Dbg_fdi ]] && [[ -t $_Dbg_fdi ]] ; then
	builtin print -- "$@"  >&${_Dbg_fdi}
    else
	builtin print -- "$@"
    fi
    
}

function _Dbg_msg_nocr {
    if [[ -n $_Dbg_fdi ]] && [[ -t $_Dbg_fdi ]] ; then
	builtin echo -n "$@" >&${_Dbg_fdi}
    else
	builtin echo -n "$@"
    fi
}

# print message to output device
function _Dbg_printf {
  typeset format
  format=$1
  shift
  if (( _Dbg_logging )) ; then
    builtin printf "$format" "$@" >>$_Dbg_logfid
  fi
  if (( ! _Dbg_logging_redirect )) ; then
    if [[ -n $_Dbg_fdi ]] && [[ -t $_Dbg_fdi ]] ; then
      builtin printf "$format" "$@" >&${_Dbg_fdi}
    else
      builtin printf "$format" "$@"
    fi
  fi
  _Dbg_msg ''
}

# Common funnel for "Undefined command" message
_Dbg_undefined_cmd() {
    if (( $# == 2 )) ; then
	_Dbg_msg "Undefined $1 subcommand \"$2\". Try \"help $1\"."
    else
	_Dbg_msg "Undefined command \"$1\". Try \"help\"."
    fi
}

