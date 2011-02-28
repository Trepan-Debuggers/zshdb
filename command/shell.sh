# -*- shell-script -*-
# Enter nested shell
#
#   Copyright (C) 2011 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_shell_temp_profile="$_Dbg_tmpdir/.zshenv"

_Dbg_help_add shell \
"shell [options]

options: 
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
--init-file option.

If you don't want variable definitions to be set, use option -V or
--no-vars. If you don't want function definitions to be set, use option
-F or --no-fns. There are several corresponding shell options. Many of 
these by nature defeate reading on saved functions and variables.

The shell that used is taken from the shell used to build the debugger 
which is: $_Dbg_shell_name. Use --shell to a different compatible shell.

Variables set or changed in the shell do not persist after the shell
is left to to back to the debugger or debugged program.
"

# FIXME: add this behavior
# By default variables set or changed in the SHELL are not saved after
# exit of the shell and back to the debugger or debugged program. 
# If you want
# to save the values of individual variables created or changed, use function
# save_var and pass in the name of the variable. For example
# 
# my_var='abc'
# save_var my_var

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
		o_fns=0;;
	    V | no-vars )
		o_vars=0;;
	    shell )
		shell=$OPTARG;;
	    norc | posix | restricted | login | l | noediting | noprofile )
		shell_opts+="--$opt"
		;;
	    * ) 
		return 1
		;;
	esac
    done
    return 0
}


_Dbg_do_shell() {
    typeset -i o_fns;  o_fns=1
    typeset -i o_vars; o_vars=1
    typeset shell_opts=''
    typeset  shell=$_Dbg_shell
		
    if (($# != 0)); then
	_Dbg_parse_shell_cmd_options $@
	(( $? != 0 )) && return
	IFS='' typeset -p o_fns o_vars
    fi

    typeset -i _Dbg_rc

    echo '# debugger shell profile' > $_Dbg_shell_temp_profile

    ((o_vars)) && _Dbg_shell_append_typesets
    ((o_fns)) && typeset -pf >> $_Dbg_shell_temp_profile

    ## echo 'save_var() { typeset -p $1 >>${_Dbg_journal} 2>/dev/null; }' >> $_Dbg_shell_temp_profile

    echo "PS1='${_Dbg_debugger_name} $ '" >>$_Dbg_shell_temp_profile

    export ZDOTDIR=$_Dbg_tmpdir
    $shell -o TYPESET_SILENT $shell_opts
    rc=$?
    ## rm -f $_Dbg_shell_temp_profile 2>&1 >/dev/null
    # . $_Dbg_journal
    _Dbg_print_location_and_command
}
