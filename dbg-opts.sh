# -*- shell-script -*-
# dbg-opts.sh - zshdb command options processing. The bane of programming.
#
#   Copyright (C) 2008 Rocky Bernstein rocky@gnu.org
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

_Dbg_usage() {
  printf "Usage: 
   ${_Dbg_pname} [OPTIONS] <script_file>

Runs $_Dbg_shell_name <script_file> under a debugger.

options:
    -h | --help             Print this help.
    -q | --quiet            Do not print introductory and quiet messages.
    -A | --annotate  LEVEL  Set the annotation level.
    -B | --basename         Show basename only on source file listings. 
                            (Needed in regression tests)
    -L | --library DIRECTORY
                            Set the directory location of library helper file: $_Dbg_main
    -c | --command STRING   Run STRING instead of a script file
    -n | --nx | --no-init   Don't run initialization files.
    -V | --version          Print the debugger version number.
    -x | --eval-command CMDFILE
                            Execute debugger commands from CMDFILE.
"
  exit 100
}

_Dbg_show_version() {
  printf "There is absolutely no warranty for $_Dbg_debugger_name.  Type \"show warranty\" for details.
"
  exit 101

}

# Script arguments before adulteration by _Dbg_parse_otps
typeset -a _Dbg_orig_script_args
_Dbg_orig_script_args=($@)

# The following globals are set by _Dbg_parse_opts. Any values set are 
# the default values.
typeset -ax _Dbg_script_args

# Use gdb-style annotate?
typeset -i _Dbg_annotate=0

# Simulate set -x?
typeset -i _Dbg_linetrace=0
typeset -i _Dbg_basename_only=0
typeset -i _Dbg_o_nx=0
typeset -i _Dbg_o_linetrace=0

# $_Dbg_tmpdir could have been set by the top-level debugger script.
[[ -z $_Dbg_tmpdir ]] && typeset _Dbg_tmpdir=/tmp


_Dbg_parse_options() {

    . ${_Dbg_libdir}/getopts_long.sh

    typeset -i _Dbg_o_quiet=0
    typeset -i _Dbg_o_version=0

    while getopts_long A:Bc:x:hL:nqTt:VX opt \
	annotate required_argument           \
	basename 0                           \
	command  required_argument           \
	eval-command required_argument       \
	cmdfile  required_argument           \
    	help     0                           \
	library  required_argument           \
	no-init  0                           \
	nx       0                           \
	quiet    0                           \
        tempdir  required_argument           \
	version  0                           \
	'' "$@"
    do
	case "$opt" in 
	    A | annotate ) 
		_Dbg_o_annotate=$OPTLARG;;
	    B | basename )
		_Dbg_basename_only=1  	;;
	    c | command )
		_Dbg_EXECUTION_STRING="$OPTLARG" ;;
	    h | help )
		_Dbg_usage		;;
	    L | library ) 		;;
	    V | version )
		_Dbg_o_version=1	;;
	    n | nx | no-init )
		_Dbg_o_nx=1		;;
	    q | quiet )
		_Dbg_o_quiet=1		;;
	    tempdir) 
		_Dbg_tmpdir=$OPTLARG	;;
	    x | eval-command )
		DBG_INPUT=$OPTLARG	;;
	    '?' )  # Path taken on a bad option
		echo  >&2 'Use -h or --help to see options.'
		exit 2                  ;;
	    * ) 
		echo "Unknown option $opt. Use -h or --help to see options." >&2
		exit 2		;;
	esac
    done
    shift "$(($OPTLIND - 1))"

    if (( ! _Dbg_o_quiet && ! _Dbg_o_version )); then 
	echo "$_Dbg_shell_name Shell Debugger, release $_Dbg_release"
	printf '
Copyright 2008 Rocky Bernstein
This is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.

'
    fi
    (( _Dbg_o_version )) && _Dbg_show_version

    if [[ -n $_Dbg_o_annotate ]] ; then
	if [[ ${_Dbg_o_annotate} == [0-9]* ]] ; then
	    _Dbg_annotate=$_Dbg_o_annotate
	    if (( _Dbg_annotate > 3 || _Dbg_annotate < 0)); then
		print "Annotation level must be less between 0 and 3. Got: $_Dbg_annotate." >&2
		print "Setting Annotation level to 0." >&2
		_Dbg_annotate=0
	    fi
	else
	    print "Annotate option should be an integer, got ${_Dbg_o_annotate}." >&2
	    print "Setting annotation level to 0." >&2
	fi
    fi
    unset _Dbg_o_annotate _Dbg_o_version _Dbg_o_quiet
    _Dbg_script_args=("$@")
}


# Stand-alone Testing. 
if [[ -n "$_Dbg_dbg_opts_test" ]] ; then
    OPTLIND=1
    _Dbg_libdir='.'
    [[ -n $_Dbg_input ]] && typeset -p _Dbg_input
    _Dbg_parse_options "$@"
    typeset -p _Dbg_annotate
    typeset -p _Dbg_linetrace
    typeset -p _Dbg_basename_only
fi
