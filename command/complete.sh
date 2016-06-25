# complete.sh - gdb-like 'complete' command
#
#   Copyright (C) 2010-2011, 2016 Rocky Bernstein <rocky@gnu.org>
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

if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    dirname=${0%/*}
    [[ $dirname == $0 ]] && top_dir='..' || top_dir=${dirname}/..
    for lib_file in help alias ; do source $top_dir/lib/${lib_file}.sh; done
fi

_Dbg_help_add complete \
'**complete** *prefix-str*...

Show command completion strings for *prefix-str*
'

#### zsh compgen's -W (words) doesn't match bash's.
#### Until we get a fix into zsh....

## Uncomment after we get a change to zsh...
## autoload -Uz bashcompinit
## bashcompinit
## zmodload -ap zsh/parameter parameters

_compgen_opt_words() {
 typeset -a words
 words=( ${~=1} )
 local find try
 find=$2
 results=(${(M)words[@]:#$find*})
}

compgen() {
  local -a results
  local opts prefix suffix job OPTARG OPTIND ret=1
  local -a name res results jids
  local -A shortopts

  emulate -L sh
  setopt kshglob noshglob braceexpand nokshautoload

  shortopts=(
    a alias b builtin c command d directory e export f file
    g group j job k keyword u user v variable
  )

  while getopts "o:A:G:C:F:P:S:W:X:abcdefgjkuv" name; do
    case $name in
      [abcdefgjkuv]) OPTARG="${shortopts[$name]}" ;&
      A)
        case $OPTARG in
	  alias) results+=( "${(k)aliases[@]}" ) ;;
	  arrayvar) results+=( "${(k@)parameters[(R)array*]}" ) ;;
	  binding) results+=( "${(k)widgets[@]}" ) ;;
	  builtin) results+=( "${(k)builtins[@]}" "${(k)dis_builtins[@]}" ) ;;
	  command)
	    results+=(
	      "${(k)commands[@]}" "${(k)aliases[@]}" "${(k)builtins[@]}"
	      "${(k)functions[@]}" "${(k)reswords[@]}"
	    )
	  ;;
	  directory)
	    setopt bareglobqual
	    results+=( ${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N-/) )
	    setopt nobareglobqual
	  ;;
	  disabled) results+=( "${(k)dis_builtins[@]}" ) ;;
	  enabled) results+=( "${(k)builtins[@]}" ) ;;
	  export) results+=( "${(k)parameters[(R)*export*]}" ) ;;
	  file)
	    setopt bareglobqual
	    results+=( ${IPREFIX}${PREFIX}*${SUFFIX}${ISUFFIX}(N) )
	    setopt nobareglobqual
	  ;;
	  function) results+=( "${(k)functions[@]}" ) ;;
	  group)
	    emulate zsh
	    _groups -U -O res
	    emulate sh
	    setopt kshglob noshglob braceexpand
	    results+=( "${res[@]}" )
	  ;;
	  hostname)
	    emulate zsh
	    _hosts -U -O res
	    emulate sh
	    setopt kshglob noshglob braceexpand
	    results+=( "${res[@]}" )
	  ;;
	  job) results+=( "${savejobtexts[@]%% *}" );;
	  keyword) results+=( "${(k)reswords[@]}" ) ;;
	  running)
	    jids=( "${(@k)savejobstates[(R)running*]}" )
	    for job in "${jids[@]}"; do
	      results+=( ${savejobtexts[$job]%% *} )
	    done
	  ;;
	  stopped)
	    jids=( "${(@k)savejobstates[(R)suspended*]}" )
	    for job in "${jids[@]}"; do
	      results+=( ${savejobtexts[$job]%% *} )
	    done
	  ;;
	  setopt|shopt) results+=( "${(k)options[@]}" ) ;;
	  signal) results+=( "SIG${^signals[@]}" ) ;;
	  user) results+=( "${(k)userdirs[@]}" ) ;;
      	  variable) results+=( "${(k)parameters[@]}" ) ;;
	  helptopic) ;;
	esac
      ;;
      F)
        COMPREPLY=()
	$OPTARG "${words[0]}" "${words[CURRENT-1]}" "${words[CURRENT-2]}"
	results+=( "${COMPREPLY[@]}" )
      ;;
      G)
        setopt nullglob
        results+=( ${~OPTARG} )
	unsetopt nullglob
      ;;
      W) _compgen_opt_words "$OPTARG" "${@[-1]}"
      ;;
      C) results+=( $(eval $OPTARG) ) ;;
      P) prefix="$OPTARG" ;;
      S) suffix="$OPTARG" ;;
      X)
        if [[ ${OPTARG[0]} = '!' ]]; then
	  results=( "${(M)results[@]:#${OPTARG#?}}" )
	else
 	  results=( "${results[@]:#$OPTARG}" )
	fi
      ;;
    esac
  done
#### End fix stuff.

  # support for the last, `word' option to compgen. Zsh's matching does a
  # better job but if you need to, comment this in and use compadd -U
  #shift $(( OPTIND - 1 ))
  #(( $# )) && results=( "${(M)results[@]:#$1*}" )

  print -l -- "$prefix${^results[@]}$suffix"
}

_Dbg_do_complete() {
    typeset -a args; args=($@)
    _Dbg_matches=()
    if (( ${#args[@]} == 2 )) ; then
	_Dbg_subcmd_complete ${args[0]} ${args[1]}
    elif (( ${#args[@]} == 1 )) ; then
	typeset -a ary
	ary=(${(k)_Dbg_debugger_commands[@]})
	IFS=' ' list=${ary[@]}
	compgen -W "${list}" "${args[0]}"
    fi
    typeset -i i
    for (( i=0;  i < ${#_Dbg_matches[@]}  ; i++ )) ; do
	_Dbg_msg ${_Dbg_matches[$i]}
    done
}

# Demo it.
if [[ 0 == ${#funcfiletrace[@]} ]] ; then
    source ./help.sh
    source ../lib/msg.sh
    _Dbg_libdir='..'
    for _Dbg_file in ${_Dbg_libdir}/command/c*.sh ; do
    	source $_Dbg_file
    done

    _Dbg_args='complete'
    _Dbg_do_help complete
    _Dbg_do_complete c
fi
