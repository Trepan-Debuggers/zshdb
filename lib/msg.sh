# -*- shell-script -*-
#   Copyright (C) 2008-2009, 2011, 2014-2015, 2017
#   Rocky Bernstein <rocky@gnu.org>
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

_Dbg_ansi_term_bold="[1m"
_Dbg_ansi_term_italic="[3m"
_Dbg_ansi_term_underline="[4m"
_Dbg_ansi_term_normal="[0m"

# Called when a dangerous action is about to be done to make sure it's
# okay. `prompt' is printed, and "yes", or "no" is solicited.  The
# user response is returned in variable $_Dbg_response and $? is set
# to 0.  _Dbg_response is set to 'error' and $? set to 1 on an error.
#

typeset -g _Dbg_response=''

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
	      read "?$_Dbg_confirm_prompt" _Dbg_response <&${_Dbg_fdi} >>$_Dbg_prompt_output || break
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
    if [[ -n $_Dbg_set_highlight ]] ; then
	_Dbg_msg "$prefix ${_Dbg_ansi_term_underline}$@${_Dbg_ansi_term_normal}"
    else
	_Dbg_msg "$prefix $@"
    fi
}

# Print an error message without the ending carriage return
function _Dbg_errmsg_no_cr {
    typeset -r prefix='**'
    _Dbg_msg_nocr "$prefix $@"
}

function _Dbg_msg {
    #if [[ -n "$_Dbg_tty" ]] && [[ -t "$_Dbg_tty" ]] ; then
	if [[ -n "$_Dbg_tty" ]] ; then
	builtin print -- "$@"  >> "$_Dbg_tty"
    else
	builtin print -- "$@"
    fi

}

function _Dbg_msg_nocr {
    #if [[ -n "$_Dbg_tty" ]] && [[ -t "$_Dbg_tty" ]] ; then
	if [[ -n "$_Dbg_tty" ]] ; then
	builtin echo -n "$@" >>"$_Dbg_tty"
    else
	builtin echo -n "$@"
    fi
}

# print message to output device
function _Dbg_printf {
    _Dbg_printf_nocr "$@"
    _Dbg_msg ''
}

# print message to output device
function _Dbg_printf_nocr {
    typeset format
    format=$1
    shift
    if (( _Dbg_logging )) ; then
	builtin printf "$format" "$@" >>$_Dbg_logfid
    fi
    if (( ! _Dbg_logging_redirect )) ; then
	#if [[ -n $_Dbg_fdi ]] && [[ -t $_Dbg_fdi ]] ; then
	if [[ -n "$_Dbg_tty" ]] ; then
	    builtin printf "$format" "$@" >>"$_Dbg_tty"
	else
	    builtin printf "$format" "$@"
	fi
    fi
}

typeset _Dbg_dashes='---------------------------------------------------'

# print message to output device
function _Dbg_section {
    if [[ -n $_Dbg_set_highlight ]] ; then
	_Dbg_msg "${_Dbg_ansi_term_bold}$@${_Dbg_ansi_term_normal}"
    else
	local -r msg="$@"
        _Dbg_msg "$msg\n${_Dbg_dashes[0,${#msg}-1]}"
    fi
}

function _Dbg_msg_rst {
    local -r msg="$@"
    if [[ -n $_Dbg_set_highlight ]] && (( _Dbg_working_term_highlight )) ; then
	typeset opts="--rst --width=$_Dbg_set_linewidth"
	typeset highlight_cmd="${_Dbg_libdir}/lib/term-highlight.py"
	typeset formatted_msg
	formatted_msg=$(echo "$msg" | $highlight_cmd $opts)
	if (( $? == 0 )) && [[ -n $formatted_msg ]] ; then
	    _Dbg_msg "$formatted_msg"
	    return
	fi
    fi
    _Dbg_msg "$msg"
}

# Common funnel for "Undefined command" message
_Dbg_undefined_cmd() {
    if (( $# == 2 )) ; then
	_Dbg_errmsg "Undefined $1 subcommand \"$2\". Try \"help $1\"."
    else
	_Dbg_errmsg "Undefined command \"$1\". Try \"help\"."
    fi
}
