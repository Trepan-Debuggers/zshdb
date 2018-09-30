# -*- shell-script -*-
# debugger command options processing. The bane of programming.
#
#   Copyright (C) 2008-2011, 2014-2016 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_usage() {
  printf "Usage:
   ${_Dbg_pname} [OPTIONS] <script_file>

Runs $_Dbg_shell_name <script_file> under a debugger.

options:
    -h | --help              Print this help.
    -q | --quiet             Do not print introductory and quiet messages.
    -A | --annotate  LEVEL   Set the annotation level.
    -B | --basename          Show basename only on source file listings.
                             (Needed in regression tests)
    --highlight {dark|light} Use dark or light background ANSI terminal sequence
                             syntax highlighting
      | --no-highlight
                             Don't use ANSI terminal sequences for syntax
                             highlight
    --init-file FILE         Source script file FILE. Similar to bash's
                             corresponding option. This option can be given
                             several times with different files.
    -L | --library DIRECTORY
                             Set the directory location of library helper file:
                             $_Dbg_main
    -c | --command STRING    Run STRING instead of a script file
    -n | --nx | --no-init    Don't run initialization files.
    -S | --style STYLE       Run use pygments STYLE for formatting source code
    -t | --tty DEV           Run using device for your programs standard input and output
    --tty_in | --terminal_in DEV   Set to ...
    -T | --tempdir DIRECTORY
                             Use DIRECTORY to store temporary files in
    -V | --version           Print the debugger version number.
    -X | --trace             Set line tracing similar to set -x
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

# Script arguments before adulteration by _Dbg_parse_opts
typeset -xa _Dbg_orig_script_args
_Dbg_orig_script_args=($@)

# The following globals are set by _Dbg_parse_opts. Any values set are
# the default values.
typeset -xa _Dbg_script_args

# Use gdb-style annotate?
typeset -i _Dbg_set_annotate=0

# Simulate set -x?
typeset -i _Dbg_set_linetrace=0

typeset -i _Dbg_set_basename=0
typeset    _Dbg_set_highlight  # Initialized below
typeset -a _Dbg_o_init_files; _Dbg_o_init_files=()
typeset -i _Dbg_o_nx=0
typeset    _Dbg_tty=''
typeset -i _Dbg_history_save=1
typeset -i _Dbg_history_size=${HISTSIZE:-256} # gdb's defaulit value
typeset    _Dbg_histfile=${ZDOTDIR:-$HOME}/.${_Dbg_debugger_name}_hist

typeset _Dbg_edit='-e'
typeset _Dbg_edit_style='emacs'
builtin bindkey -e

typeset -ix _Dbg_working_term_highlight

if ${_Dbg_libdir}/lib/term-highlight.py -V 2>/dev/null  1>/dev/null ; then
    _Dbg_working_term_highlight=1
else
    _Dbg_working_term_highlight=0
fi

typeset -x _Dbg_set_style=''


# If we can do highlighting, do it.
if ((  _Dbg_working_term_highlight )) ; then
    _Dbg_set_highlight="light"
else
    _Dbg_set_highlight=''
fi

# $_Dbg_tmpdir could have been set by the top-level debugger script.
[[ -z $_Dbg_tmpdir ]] && typeset _Dbg_tmpdir=/tmp

_Dbg_check_tty() {
    (( $# < 1 )) && return 1
    typeset tty=$1
    if [[ $tty != '&1' ]] ; then
        if ! $(touch "$tty" >/dev/null 2>/dev/null); then
            _Dbg_errmsg "Can't access $tty for writing."
            return 1
        fi
        if [[ ! -w "$tty" ]] ; then
            _Dbg_errmsg "tty $tty needs to be writable"
            return 1
        fi
        _Dbg_tty="$tty"
        _Dbg_prompt_output="$_Dbg_tty"
    fi
    return 0
}

_Dbg_parse_options() {

    . ${_Dbg_libdir}/getopts_long.sh

    typeset -i _Dbg_o_quiet=0
    typeset -i _Dbg_o_version=0

    while getopts_long A:Bc:x:hL:nqTS:t:V opt    \
	annotate required_argument               \
	basename no_argument                     \
	command  required_argument               \
	eval-command required_argument           \
	cmdfile      required_argument           \
    	help         no_argument                 \
    	highlight    required_argument           \
	init-file    required_argument           \
	library      required_argument           \
	no-highlight no_argument                 \
	no-init      no_argument                 \
	nx           no_argument                 \
	quiet        no_argument                 \
        tempdir      required_argument           \
    	style        required_argument           \
        tty          required_argument           \
        tty_in       required_argument           \
        terminal_in  required_argument           \
	version      no_argument                 \
	'' "$@"
    do
	case "$opt" in
	    A | annotate )
		_Dbg_o_annotate=$OPTLARG;;
	    B | basename )
		_Dbg_set_basename=1  	;;
	    c | command )
		_Dbg_EXECUTION_STRING="$OPTLARG" ;;
	    h | help )
		_Dbg_usage		;;
	    highlight )
		case "$OPTLARG" in
		    light | dark )
			_Dbg_set_highlight=$OPTLARG
		    ;;
		* )
		    print "Expecting 'dark' or 'light', got \"${OPTLARG}\"" >&2
		    exit 2
		esac

		if (( ! _Ddg_working_term_highlight )) ; then
		    echo "Can't run term-highlight.py; '--highlight' forced off" >&2
		    _Dbg_set_highlight=''
		fi
		;;
	    no-highlight )
		_Dbg_set_highlight=''  	;;
	    init-file )
		_Dbg_o_init_files+="$OPTLARG"
		;;
	    L | library ) 		;;
	    V | version )
		_Dbg_o_version=1	;;
	    n | nx | no-init )
		_Dbg_o_nx=1		;;
	    q | quiet )
		_Dbg_o_quiet=1		;;
	    S | style)
		if (( $_Dbg_working_term_highlight )) ; then
		    _Dbg_set_style=$OPTLARG
		else
		    echo "Can't run term-highlight.py; '--style' option ignored" >&2
		fi
		;;
	    t | tty)
		_Dbg_tty=$OPTLARG	;;
	    tempdir)
		_Dbg_tmpdir=$OPTLARG	;;
            terminal_in | tty_in )
                _Dbg_tty_in="$OPTLARG"
                ;;
	    x | eval-command )
		DBG_INPUT=$OPTLARG	;;
	    X | trace )
		_Dbg_set_linetrace=1        ;;
	    '?' )  # Path taken on a bad option
		echo  >&2 'Use -h or --help to see options.'
		exit 2                  ;;
	    * )
		echo "Unknown option $opt. Use -h or --help to see options." >&2
		exit 2		;;
	esac
    done
    shift "$(($OPTLIND - 1))"

    if (( _Dbg_o_version )) ; then
	_Dbg_do_show_version
	exit 0
    elif (( ! _Dbg_o_quiet )) && [[ -n $_Dbg_shell_name ]] && \
	[[ -n $_Dbg_release ]] ; then
	echo "$_Dbg_shell_name debugger, $_Dbg_debugger_name, release $_Dbg_release"
	printf '
Copyright 2008-2011, 2014, 2016-2018 Rocky Bernstein
This is free software, covered by the GNU General Public License, and you are
welcome to change it and/or distribute copies of it under certain conditions.

'
    fi
    (( _Dbg_o_version )) && _Dbg_show_version

    if [[ -n $_Dbg_o_annotate ]] ; then
	if [[ ${_Dbg_o_annotate} == [0-9]* ]] ; then
	    _Dbg_set_annotate=$_Dbg_o_annotate
	    if (( _Dbg_set_annotate > 3 || _Dbg_set_annotate < 0)); then
		echo "Annotation level must be less between 0 and 3. Got: $_Dbg_set_annotate." >&2
		echo "Setting Annotation level to 0." >&2
		_Dbg_set_annotate=0
	    fi
	else
	    echo "Annotate option should be an integer, got ${_Dbg_o_annotate}." >&2
	    echo "Setting annotation level to 0." >&2
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
    typeset -p _Dbg_set_annotate
    typeset -p _Dbg_set_linetrace
    typeset -p _Dbg_set_basename
fi
