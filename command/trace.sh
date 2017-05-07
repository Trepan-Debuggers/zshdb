# -*- shell-script -*-
#
#   Copyright (C) 2008, 2010, 2016 Rocky Bernstein rocky@gnu.org
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

# Wrap "set -x .. set +x" around a call to function $1.
# Normally we also save and restrore any trap DEBUG functions. However
# If $2 is 0 we will won't.
# The wrapped function becomes the new function and the original
# function is called old_$1.
# $? is 0 if successful.

_Dbg_help_add trace \
'**trace** *function*

trace alias *alias*

Set "xtrace" (set -x) tracing when *function* is called.
'

function _Dbg_do_trace {
    if (($# == 0)) ; then
        _Dbg_errmsg "_Dbg_do_trace: missing function name."
        return 2
    fi
    typeset fn=$1
    if [[ $fn == 'alias' ]]; then
        shift
        _Dbg_do_trace_alias "$@"
        return $?
    fi

    typeset -ri clear_debug_trap=${2:-1}
    _Dbg_is_function "$fn" $_Dbg_set_debug || {
        _Dbg_errmsg "_Dbg_do_trace: \"$fn\" is not a function."
        return 3
    }
    cmd=old_$(typeset -f -- "$fn") || {
        return 4
    }
    typeset -ft $fn
    return 0
}

function _Dbg_do_trace_alias {
    if (($# == 0)) ; then
        _Dbg_errmsg "_Dbg_do_trace_alias: missing alias name."
        return 2
    fi
    typeset al=$1
    if _Dbg_is_alias "$al" ; then
        alias_body=$(alias $1)
        alias_body="set -x; $alias_body; set +x"
        alias ${al}=${alias_body}
    else
        _Dbg_errmsg "_Dbg_do_trace_alias: \"$al\" is not an alias."
        return 3
    fi
    return 0
}

_Dbg_help_add untrace \
'**untrace** *function*

Untrace previuosly traced *function*.
'

# Undo wrapping fn
# $? is 0 if successful.
function _Dbg_do_untrace {
    typeset -r fn=$1
    if [[ -z $fn ]] ; then
        _Dbg_errmsg "untrace: missing or invalid function name."
        return 2
    fi
    _Dbg_is_function "$fn" $_Dbg_set_debug || {
        _Dbg_errmsg "untrace: function \"$fn\" is not a function."
        return 3
    }
    typeset +ft $fn
    return 0
}
