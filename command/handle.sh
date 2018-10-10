# -*- shell-script -*-
# handle.sh - gdb-like "handle" debugger command
#
#   Copyright (C) 2002-2006, 2008, 2010-2011,
#   2016 Rocky Bernstein <rocky@gnu.org>
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


# Process debugger "handle" command.

## Punt on for now...
# _Dbg_help_add handle \
# "handle SIGNAL ACTION -- Specify how to handle SIGNAL.

# SIGNAL is a signal name like SIGSEGV, but numeric signals like 11
# (which is usually equivalent on \*nix systems) is okay too.

# ACTION is one of \"stop\", \"nostop\", \"print\", and
# \"noprint\". \"Stop\" indicates entering debugger if this signal
# happens. \"Print\" indicates printing a message if this signal is
# encountered. \"Stack\" is like \"print\" but except the entire call
# stack is printed. Prefacing these actions with \"no\" indicates not to
# do the indicated action."

_Dbg_help_add handle \
"**handle** *signal* *action*

Specify how to handle *signal*.

*signal* is a signal name like SIGSEGV, but numeric signals like 11
(which is usually equivalent on \*nix systems) is okay too.

*action* is one of \"stop\", \"nostop\", \"print\", and
\"noprint\". \"Stop\" indicates entering debugger if this signal
happens. \"Print\" indicates printing a message if this signal is
encountered. \"Stack\" is like \"print\" but except the entire call
stack is printed. Prefacing these actions with \"no\" indicates not to
do the indicated action."

_Dbg_do_handle() {
    typeset sig=$1
    typeset cmd=$2
    typeset -i signum
    if [[ -z $sig ]] ; then
        _Dbg_errmsg "Missing signal name or signal number."
        # return 1
        return 0
    fi

    if [[ $sig == [0-9]*([0-9]) ]]; then
        signame=$(_Dbg_signum2name $sig)
        typeset -i rc=$?
        if (( rc == 0 )) ; then
            typeset -i check_num
            check_num=$(builtin kill -l $signame)
            rc=$?
            if ((rc == 0)) ; then
                (( check_num != sig )) && rc=1
            fi
        fi

        if (( rc != 0 )) ; then
            _Dbg_errmsg "Bad signal number: $sig"
            # return 2
            return 0
        fi
        signum=sig
    else
        signum=$(_Dbg_name2signum $sig)
        if (( $? != 0 )) ; then
            _Dbg_errmsg "Bad signal name: $sig"
            # return 3
            return 0
        fi
    fi

    [[ -n ${Dbg_sig_print[$signum]} ]] || _Dbg_init_trap $signame $signum
    case $cmd in
        nop | nopr | nopri | noprin | noprint )
            _Dbg_sig_print[signum]='noprint'
            # noprint implies nostop
            _Dbg_sig_stop[signum]='stop'
            ;;

        nosta | nostac | nostack )
            _Dbg_sig_show_stack[signum]='nostack'
            ;;

        nosto | nostop  )
            _Dbg_sig_stop[signum]='nostop'
            ;;

        p | pr | pri | prin | print )
            _Dbg_sig_print[signum]='print'
            ;;

        sta | stac | stack )
            _Dbg_sig_show_stack[signum]='showstack'
            ;;

        sto | stop )
            _Dbg_sig_stop[signum]='stop'
            # stop keyword implies print
            _Dbg_sig_print[signum]='print'
            ;;
        * )
            if (( !cmd )) ; then
                _Dbg_errmsg \
                    "Need to give a command: stop, nostop, stack, nostack, print, noprint"
                # return 4
                return 0
            else
                _Dbg_errmsg "Invalid handler command $cmd"
                # return 5
                return 0
            fi
            ;;
    esac

    return 0
}
