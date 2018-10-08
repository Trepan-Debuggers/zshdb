# -*- shell-script -*-
# Eval and Print commands.
#
#   Copyright (C) 2008, 2010-2011, 2014-2015, 2017 Rocky Bernstein
#   <rocky@gnu.org>
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

# temp file for internal eval'd commands
typeset _Dbg_evalfile=$(_Dbg_tempname eval)

# _Dbg_complete_level_1_data[eval?]=\
#   '\$(typeset extracted; \
#     _Dbg_eval_extract_condition "$_Dbg_source_line"; echo $extracted)'

_Dbg_complete_eval() {
    echo $ZSH_DEBUG_CMD
}

_Dbg_complete_level_1_data[eval]='-Q_Dbg_complete_eval'

_Dbg_help_add eval \
'**eval** *cmd*

**eval**

**eval?**

In the first form *cmd* is a string; *cmd* is a string sent to special
shell builtin eval.

In the second form, use evaluate the current source line text.

Often when one is stopped at the line of the first part of an "if",
"elif", "case", "return", "while" compound statement or an assignment
statement, one wants to eval is just the expression portion.  For
this, use eval?. Actually, any alias that ends in ? which is aliased
to eval will do thie same thing.

If no string is given, we run the string from the current source code
about to be run. If the command ends `?` (via an alias) and no string is
given, the following translations occur:

    {if|elif} <expr> [; then] => <expr>
    while <expr> [; do]?      => <expr>
    return <expr>             => <expr>
    <var>=<expr>              => <expr>

See also:
---------

**set autoeval**, **print** and **examine**.'

typeset -i _Dbg_show_eval_rc; _Dbg_show_eval_rc=1

_Dbg_do_eval() {

    print ". ${_Dbg_libdir}/lib/set-d-vars.sh" > "$_Dbg_evalfile"
    if (( $# == 0 )) ; then
        # FIXME: add parameter to get unhighlighted line, or
        # always save a copy of that in _Dbg_sget_source_line
        typeset source_line
        typeset highlight_save=$_Dbg_set_highlight
        _Dbg_set_highlight=''
        _Dbg_get_source_line
        typeset source_line_save="$source_line"

        # Were we called via ? as the suffix?
        typeset suffix
        suffix=${_Dbg_orig_cmd[-1,-1]}

        # ZSH_DEBUG_CMD is preferable to _Dbg_source_line in that we
        # know is a complete statement. But to determine if it is a
        # compound statement like "if .. ; then .. fi we'd prefer just
        # to go with the line shown and pehraps use eval? to shorten
        # that.  The heuristic we use to determine a compound statement
        # is just whether the the length of text of the the current is less
        # than the length of the full command in ZSH_DEBUG_CMD
        if (( ${#source_line} > ${#ZSH_DEBUG_CMD} )) ; then
            source_line=$ZSH_DEBUG_CMD
        fi
        if [[ '?' == "$suffix" ]] ; then
            typeset extracted
            _Dbg_eval_extract_condition "$source_line"
            source_line="$extracted"
            source_line_save="$extracted"
        fi

        print "$source_line" >> "$_Dbg_evalfile"
        _Dbg_msg "eval: ${source_line}"
        _Dbg_source_line="$source_line_save"
        _Dbg_set_highlight=$_Dbg_highlight_save
    else
        print "$@" >> "$_Dbg_evalfile"
    fi
    print '_Dbg_rc=$?' >> "$_Dbg_evalfile"
    typeset -i _Dbg_rc
    if [[ -t $_Dbg_fdi  ]] ; then
        _Dbg_set_dol_q $_Dbg_debugged_exit_code
        . $_Dbg_evalfile >>"$_Dbg_tty"
    else
        _Dbg_set_dol_q $_Dbg_debugged_exit_code
        . $_Dbg_evalfile
    fi
    (( _Dbg_show_eval_rc )) && _Dbg_msg "\$? is $_Dbg_rc"
    # We've reset some variables like IFS and PS4 to make eval look
    # like they were before debugger entry - so reset them now.
    _Dbg_set_debugger_internal
    _Dbg_last_cmd='eval'
    return 0
}

_Dbg_alias_add 'eval?' 'eval'
_Dbg_alias_add 'ev' 'eval'
_Dbg_alias_add 'ev?' 'eval'

# The arguments in the last "print" command.
typeset _Dbg_last_print_args=''

_Dbg_help_add print \
'print EXPRESSION -- Print EXPRESSION.

EXPRESSION is a string like you would put in a print statement.
See also eval.

The difference between eval and print. Suppose cmd has the value "ls".

print $cmd # prints "ls"
eval $cmd  # runs an ls command
'

_Dbg_do_print() {
    typeset _Dbg_expr; _Dbg_expr=${@:-"$_Dbg_last_print_args"}
    typeset dq_expr; dq_expr=$(_Dbg_esc_dq "$_Dbg_expr")
    typeset -i _Dbg_show_eval_rc=0
    _Dbg_do_eval _Dbg_msg "$_Dbg_expr"
    typeset -i rc=$?
    _Dbg_last_print_args="$dq_expr"
    return 0
    # return $rc
}

_Dbg_alias_add 'pr' 'print'
