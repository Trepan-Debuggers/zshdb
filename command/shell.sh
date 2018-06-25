# -*- shell-script -*-
# Enter nested shell
#
#   Copyright (C) 2011, 2014, 2016, 2018 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_restore_info="${_Dbg_tmpdir}/${_Dbg_debugger_name}_restore_$$"

_Dbg_help_add shell \
"**shell** [*options*]

Options:
--------

   --no-fns  | -F  : don't copy in function definitions from parent shell
   --no-vars | -V  : don't copy in variable definitions
   --shell SHELL_NAME
   --posix         : corresponding shell option
   --login | l     : corresponding shell option
   --noprofile     : corresponding shell option
   --norc          : corresponding shell option

Enter a nested shell, not a subshell. Before entering the shell
current variable definitions and function definitions are stored in
profile $_Dbg_shell_temp_profile. which is is read in via the
**--init-file** option.

If you don't want variable definitions to be set, use option **-V** or
**--no-vars**. If you don't want function definitions to be set, use
option **-F** or **--no-fns**. There are several corresponding shell
options. Many of these by nature defeate reading on saved functions
and variables.

The shell that used is taken from the shell used to build the debugger
which is: $_Dbg_shell_name. Use **--shell** to use a different
compatible shell.

By default, variables set or changed in the shell do not persist after
the shell is left to to back to the debugger or debugged program.

However you can tag variables to persist by running the function
'save_vars' which takes a list of variable names. You can run this
as many times as you want with as many variable names as you want.

For example:
  save_vars PROFILE PARSER
marks variable PROFILE and PARSER to be examined and their values used
in the trap EXIT of the shell.
"

_Dbg_parse_shell_cmd_options() {
    OPTLIND=''
    while getopts_long lFV opt  \
        no-fns  0               \
        login no_argument       \
        shell required_argument \
        no-vars 0               \
        '' $@
    do
        case "$opt" in
            F | no-fns )
                _Dbg_o_fns=0;;
            V | no-vars )
                _Dbg_o_vars=0;;
            shell )
                shell=$OPTARG;;
            norc | posix | restricted | login | l | noediting | noprofile )
                _Dbg_shell_opts+="--$opt"
                ;;
            * )
                return 1
                ;;
        esac
    done
    return 0
}


_Dbg_do_shell() {
    typeset -i _Dbg_o_fns;  _Dbg_o_fns=1
    typeset -i _Dbg_o_vars; _Dbg_o_vars=1
    typeset _Dbg_shell_opts=''
    typeset  shell=$_Dbg_shell

    if (($# != 0)); then
        _Dbg_parse_shell_cmd_options $@
        (( $? != 0 )) && return
    fi

    typeset -i _Dbg_rc
    _Dbg_shell_new_shell_profile $_Dbg_o_vars _$Dbg_o_fns

    # Set prompt in new shell
    echo "PS1='${_Dbg_debugger_name} $ '" >>$_Dbg_shell_temp_profile
    ZDOTDIR=$_Dbg_tmpdir $shell -o TYPESET_SILENT $shell_opts
    rc=$?
    _Dbg_restore_from_nested_shell
    # FIXME: put in _Dbg_restore_from_nested_shell
    (( 1 == _Dbg_running )) && _Dbg_print_location_and_command
}

_Dbg_alias_add sh shell
_Dbg_alias_add zsh shell
