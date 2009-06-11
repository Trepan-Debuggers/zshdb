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

# Add escapes to a string $1 so that when it is read back using
# eval echo "$1" it is the same as echo $1.
function _Dbg_errmsg {
    typeset -r prefix='**'
    _Dbg_msg "$prefix $@"
}

# Print an error message without the ending carriage return
function _Dbg_errmsg_no_cr {
    typeset -r prefix='**'
    _Dbg_msg_no_cr "$prefix $@"
}

function _Dbg_msg {
    if [[ -t $_Dbg_fdi  ]] ; then
	builtin print -- "$@"  >&${_Dbg_fdi}
    else
	builtin print -- "$@"
    fi
}

function _Dbg_msg_nocr {
    if [[ -t $_Dbg_fdi  ]] ; then
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
    if [[ -t $_Dbg_fdi ]] ; then
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

