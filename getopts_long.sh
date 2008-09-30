#! /bin/echo Usage:.
# 
# getopts_long -- POSIX shell getopts with GNU-style long option support
#
# Copyright 2005-2008 Stephane Chazelas <stephane_chazelas@yahoo.fr>
# 
# Permission to use, copy, modify, distribute, and sell this software and
# its documentation for any purpose is hereby granted without fee, provided
# that the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or
# implied warranty.


getopts_long() {
  # args: shortopts, var, [name, type]*, "", "$@"
  #
  # getopts_long parses command line arguments. It works like the
  # getopts shell built-in command except that it also recognises long
  # options a la GNU.
  #
  # You must provide getopts_long with the list of supported single
  # letter options in the same format as getopts', followed by the
  # variable name you want getopts_long to return the current processed
  # option in, followed by the list of long option names (without the
  # leading "--") and types (0 or no_argument, 1 or required_argument,
  # 2 or optional_argument). The end of the long option specification
  # is indicated by an empty argument. Then follows the list of
  # arguments to be parsed.
  #
  # The $OPTLIND variable must be set to 1 before the first call of the
  # getopts_long function to process a given list of arguments.
  #
  # getopts_long returns the value of the current option in the variable
  # whose name is provided as its second argument (be careful to avoid
  # variables that have a special signification to getopts_long or the
  # shell or any other tool you may call from your script). If the
  # current option is a single letter option, then it is returned
  # without the leading "-". If it's a long option (possibly
  # abbreviated), then the full name of the option (without the leading
  # "--") is returned. If the option has an argument, then it is stored
  # in the $OPTLARG variable. If the current option is not recognised,
  # or if it is provided with an argument while it is not expecting one
  # (as in --opt=value) or if it is not provided with an argument while
  # it is expecting one, or if the option is so abbreviated that it is
  # impossible to identify the option uniquely, then:
  #   - if the short option specifications begin with ":", getopts_long
  #     returns ":" in the output variable and $OPTLARG contains the
  #     faulty option name (in full except in the case of the ambiguous
  #     or bad option) and $OPTLERR contains the error message.
  #   - if not, then getopts_long behaves the same as above except that
  #     it returns "?" instead of ":", leaves $OPTLARG unset and
  #     displays the error message on stderr.
  #
  # The exit status of getopts_long is 0 unless the end of options is
  # reached or an error is encountered in the syntax of the getopts_long
  # call.
  #
  # After getopts_long has finished processing the options, $OPTLIND
  # contains the index of the first non-option argument or $# + 1 if
  # there's no non-option argument.
  #
  # The "=" character is not allowed in a long option name. Any other
  # character is. "-" and ":" are not allowed as short option names. Any
  # other character is. If a short option appears more than once in the
  # specification, the one with the greatest number of ":"s following it
  # is retained. If a long option name is provided more than once, only
  # the first one is taken into account. Note that if you have both a -a
  # and --a option, there's no way to differentiate them. Beside the
  # $OPTLIND, $OPTLARG, and $OPTLERR, getopts_long uses the $OPTLPENDING
  # variable to hold the remaining options to be processed for arguments
  # with several one-letter options. That variable shouldn't be used
  # anywhere else in your script. Those 4 variables are the only ones
  # getopts_long may modify.
  #
  # Dependency: only POSIX utilities are called by that function. They
  # are "set", "unset", "shift", "break", "return", "eval", "command",
  # ":", "printf" and "[". Those are generally built in the POSIX
  # shells. Only "printf" has been known not to be in some old versions
  # of bash, zsh or ash based shells.
  #
  # Differences with the POSIX getopts:
  #  - if an error is detected during the parsing of command line
  #    arguments, the error message is stored in the $OPTLERR variable
  #  - in the single-letter option specification, if a letter is
  #    followed by 2 colons ("::"), then the option can have an optional
  #    argument as in GNU getopt(3). In that case, the argument must
  #    directly follow the option as in -oarg (not -o arg).
  #  - there must be an empty argument to mark the end of the option
  #    specification.
  #  - long options starting with "--" are supported.
  #
  # Differences with GNU getopt_long(3):
  #  - getopts_long doesn't allow options to be interspersed with other
  #    arguments (as if POSIXLY_CORRECT was set for GNU getopt_long(3))
  #  - there's no linkage of any sort between the short and long
  #    options. The caller is responsible of that (see example below).
  #
  # Compatibility:
  #  getopts_long code is (hopefully) POSIX.2/SUSv3 compliant. It won't
  #  work with the Bourne/SystemV shell. Use /usr/xpg4/bin/sh or ksh or
  #  bash on Solaris.
  #  It has been tested successfully with:
  #    - bash 3.0 (patch level 16) on Cygwin
  #    - zsh 4.2.4 on Solaris 2.7
  #    - /usr/xpg4/bin/sh (same as /usr/bin/ksh) (ksh88i) on Solaris 2.7
  #    - /usr/dt/bin/dtksh (ksh93d) on Solaris 2.7
  #    - /usr/bin/ksh (pdksh 5.2.14) on Linux
  #    - zsh 3.0.6 on Solaris 2.8
  #    - bash 2.0.3 on Solaris 2.8
  #    - dash 0.5.2 on Linux
  #    - bash 2.05b (patch level 0) on Linux
  #    - ksh93p and ksh93q on Linux
  #
  #  It is known to fail with those non-POSIX compliant shells:
  #    - /bin/sh on Solaris
  #    - /usr/bin/sh on Cygwin
  #    - bash 1.x
  #
  # Bugs:
  #  please report them to <stephane_chazelas@yahoo.fr>
  #
  # Example:
  #
  # verbose=false opt_bar=false bar=default_bar foo=default_foo
  # opt_s=false opt_long=false
  # OPTLIND=1
  # while getopts_long :sf:b::vh opt \
  #   long 0 \
  #   foo required_argument \
  #   bar 2 \
  #   verbose no_argument \
  #   help 0 "" "$@"
  # do
  #   case "$opt" in
  #     s) opt_s=true;;
  #     long) opt_long=true;;
  #     v|verbose) verbose=true;;
  #     h|help) usage; exit 0;;
  #     f|foo) foo=$OPTLARG;;
  #     b|bar) bar=${OPTLARG-$bar};;
  #     :) printf >&2 '%s: %s\n' "${0##*/}" "$OPTLERR"
  #        usage
  #        exit 1;;
  #   esac
  # done
  # shift "$(($OPTLIND - 1))"
  # # process the remaining arguments

  [ -n "${ZSH_VERSION+z}" ] && emulate -L sh

  unset OPTLERR OPTLARG || :

  case "$OPTLIND" in
    "" | 0 | 1 | *[!0-9]*)
      # First time in the loop. Initialise the parameters.
      OPTLIND=1
      OPTLPENDING=
      ;;
  esac

  if [ "$#" -lt 2 ]; then
    printf >&2 'getopts_long: not enough arguments\n'
    return 1
  fi

  # validate variable name. Need to fix locale for character ranges.
  LC_ALL=C command eval '
    case "$2" in
      *[!a-zA-Z_0-9]*|""|[0-9]*)
	printf >&2 "getopts_long: invalid variable name: \`%s'\''\n" "$2"
	return 1
	;;
    esac'

  # validate short option specification
  case "$1" in
    ::*|*:::*|*-*)
      printf >&2 "getopts_long: invalid option specification: \`%s'\n" "$1"
      return 1
      ;;
  esac

  # validate long option specifications

  # POSIX shells only have $1, $2... as local variables, hence the
  # extensive use of "set" in that function.

  set 4 "$@"
  while :; do
    if
      [ "$1" -gt "$#" ] || {
	eval 'set -- "${'"$1"'}" "$@"'
	[ -n "$1" ] || break
	[ "$(($2 + 2))" -gt "$#" ]
      }
    then
      printf >&2 "getopts_long: long option specifications must end in an empty argument\n"
      return 1
    fi
    eval 'set -- "${'"$(($2 + 2))"'}" "$@"'
    # $1 = type, $2 = name, $3 = $@
    case "$2" in
      *=*)
	printf >&2 "getopts_long: invalid long option name: \`%s'\n" "$2"
	return 1
	;;
    esac
    case "$1" in
      0 | no_argument) ;;
      1 | required_argument) ;;
      2 | optional_argument) ;;
      *)
	printf >&2 "getopts_long: invalid long option type: \`%s'\n" "$1"
	return 1
	;;
    esac
    eval "shift 3; set $(($3 + 2))"' "$@"'
  done
  shift

  eval "shift; set $(($1 + $OPTLIND))"' "$@"'

  # unless there are pending short options to be processed (in
  # $OPTLPENDING), the current option is now in ${$1}

  if [ -z "$OPTLPENDING" ]; then
    [ "$1" -le "$#" ] || return 1
    eval 'set -- "${'"$1"'}" "$@"'

    case "$1" in
      --)
        OPTLIND=$(($OPTLIND + 1))
	return 1
	;;
      --*)
        ;;
      -?*)
        OPTLPENDING="${1#-}"
	shift
	;;
      *)
        return 1
	;;
    esac
    OPTLIND=$(($OPTLIND + 1))
  fi

  if [ -n "$OPTLPENDING" ]; then
    # WA for zsh and bash 2.03 bugs:
    OPTLARG=${OPTLPENDING%"${OPTLPENDING#?}"}
    set -- "$OPTLARG" "$@"
    OPTLPENDING="${OPTLPENDING#?}"
    unset OPTLARG

    # $1 = current option = ${$2+1}, $3 = $@

    case "$1" in
      [-:])
	OPTLERR="bad option: \`-$1'"
	case "$3" in
	  :*)
	    eval "$4=:"
	    OPTLARG="$1"
	    ;;
	  *)
	    printf >&2 '%s\n' "$OPTLERR"
	    eval "$4='?'"
	    ;;
	esac
	;;

      *)
	case "$3" in
	  *"$1"::*) # optional argument
	    eval "$4=\"\$1\""
	    if [ -n "$OPTLPENDING" ]; then
	      # take the argument from $OPTLPENDING if any
	      OPTLARG="$OPTLPENDING"
	      OPTLPENDING=
	    fi
	    ;;

	  *"$1":*) # required argument
	    if [ -n "$OPTLPENDING" ]; then
	      # take the argument from $OPTLPENDING if any
	      OPTLARG="$OPTLPENDING"
	      eval "$4=\"\$1\""
	      OPTLPENDING=
	    else
	      # take the argument from the next argument
	      if [ "$(($2 + 2))" -gt "$#" ]; then
		OPTLERR="option \`-$1' requires an argument"
		case "$3" in
		  :*)
		    eval "$4=:"
		    OPTLARG="$1"
		    ;;
		  *)
		    printf >&2 '%s\n' "$OPTLERR"
		    eval "$4='?'"
		    ;;
		esac
	      else
		OPTLIND=$(($OPTLIND + 1))
		eval "OPTLARG=\"\${$(($2 + 2))}\""
		eval "$4=\"\$1\""
	      fi
	    fi
	    ;;

	  *"$1"*) # no argument
	    eval "$4=\"\$1\""
	    ;;
	  *)
	    OPTLERR="bad option: \`-$1'"
	    case "$3" in
	      :*)
		eval "$4=:"
		OPTLARG="$1"
		;;
	      *)
		printf >&2 '%s\n' "$OPTLERR"
		eval "$4='?'"
		;;
	    esac
	    ;;
	esac
	;;
    esac
  else # long option

    # remove the leading "--"
    OPTLPENDING="$1"
    shift
    set 6 "${OPTLPENDING#--}" "$@"
    OPTLPENDING=

    while
      eval 'set -- "${'"$1"'}" "$@"'
      [ -n "$1" ]
    do
      # $1 = option name = ${$2+1}, $3 => given option = ${$4+3}, $5 = $@

      case "${3%%=*}" in
	"$1")
	  OPTLPENDING=EXACT
	  break;;
      esac

      # try to see if the current option can be seen as an abbreviation.
      case "$1" in
	"${3%%=*}"*)
	  if [ -n "$OPTLPENDING" ]; then
	    [ "$OPTLPENDING" = AMBIGUOUS ] || eval '[ "${'"$(($OPTLPENDING + 2))"'}" = "$1" ]' ||
	      OPTLPENDING=AMBIGUOUS
	      # there was another different option matching the current
	      # option. The eval thing is in case one option is provided
	      # twice in the specifications which is OK as per the
	      # documentation above
	  else
	    OPTLPENDING="$2"
	  fi
	  ;;
      esac
      eval "shift 2; set $(($2 + 2)) "'"$@"'
    done

    case "$OPTLPENDING" in
      AMBIGUOUS)
	OPTLERR="option \`--${3%%=*}' is ambiguous"
	case "$5" in
	  :*)
	    eval "$6=:"
	    OPTLARG="${3%%=*}"
	    ;;
	  *)
	    printf >&2 '%s\n' "$OPTLERR"
	    eval "$6='?'"
	    ;;
	esac
	OPTLPENDING=
	return 0
	;;
      EXACT)
        eval 'set "${'"$(($2 + 2))"'}" "$@"'
	;;
      "")
	OPTLERR="bad option: \`--${3%%=*}'"
	case "$5" in
	  :*)
	    eval "$6=:"
	    OPTLARG="${3%%=*}"
	    ;;
	  *)
	    printf >&2 '%s\n' "$OPTLERR"
	    eval "$6='?'"
	    ;;
	esac
	OPTLPENDING=
	return 0
	;;
      *)
        # we've got an abbreviated long option.
	shift
        eval 'set "${'"$(($OPTLPENDING + 1))"'}" "${'"$OPTLPENDING"'}" "$@"'
	;;
    esac

    OPTLPENDING=

    # $1 = option type, $2 = option name, $3 unused,
    # $4 = given option = ${$5+4}, $6 = $@

    case "$4" in
      *=*)
	case "$1" in
	  1 | required_argument | 2 | optional_argument)
	    eval "$7=\"\$2\""
	    OPTLARG="${4#*=}"
	    ;;
	  *)
	    OPTLERR="option \`--$2' doesn't allow an argument"
	    case "$6" in
	      :*)
		eval "$7=:"
		OPTLARG="$2"
		;;
	      *)
		printf >&2 '%s\n' "$OPTLERR"
		eval "$7='?'"
		;;
	    esac
	    ;;
	esac
	;;

      *)
        case "$1" in
	  1 | required_argument)
	    if [ "$(($5 + 5))" -gt "$#" ]; then
	      OPTLERR="option \`--$2' requires an argument"
	      case "$6" in
		:*)
		  eval "$7=:"
		  OPTLARG="$2"
		  ;;
		*)
		  printf >&2 '%s\n' "$OPTLERR"
		  eval "$7='?'"
		  ;;
	      esac
	    else
	      OPTLIND=$(($OPTLIND + 1))
	      eval "OPTLARG=\"\${$(($5 + 5))}\""
	      eval "$7=\"\$2\""
	    fi
	    ;;
	  *)
	    # optional argument (but obviously not provided) or no
	    # argument
	    eval "$7=\"\$2\""
	    ;;
	esac
	;;
    esac
  fi
  return 0
}

# testing code
if [ -n "$_Dbg_getopts_long_test" ]; then
test_getopts_long() {
  expected="$1" had=
  shift
  OPTLIND=1

  while err="$(set +x;getopts_long "$@" 2>&1 > /dev/null)"
    getopts_long "$@" 2> /dev/null; do
    eval "opt=\"\$$2\""
    had="$had|$opt@${OPTLARG-unset}@${OPTLERR-unset}@$err"
  done
  had="$had|$OPTLIND|$err"

  if [ "$had" = "$expected" ]; then
    echo PASS
  else
    echo FAIL
    printf 'Expected: %s\n     Got: %s\n' "$expected" "$had"
  fi
}
while IFS= read -r c && IFS= read -r e; do
  printf '+ %-72s ' "$c"
  #set -x
  eval "test_getopts_long \"\$e\" $c"
done << \EOF
: a
|1|getopts_long: long option specifications must end in an empty argument
:a opt "" -a
|a@unset@unset@|2|
:a opt "" -a b
|a@unset@unset@|2|
:a opt "" -a -a
|a@unset@unset@|a@unset@unset@|3|
:a opt "" -ab
|a@unset@unset@|:@b@bad option: `-b'@|2|
:a: opt "" -ab
|a@b@unset@|2|
:a: opt "" -a b
|a@b@unset@|3|
:a: opt "" -a -a
|a@-a@unset@|3|
:a: opt "" -a
|:@a@option `-a' requires an argument@|2|
:a:: opt "" -a
|a@unset@unset@|2|
:a:: opt "" -ab
|a@b@unset@|2|
:a:: opt "" -a b
|a@unset@unset@|2|
:a:: opt "" -a -a
|a@unset@unset@|a@unset@unset@|3|
:a:: opt "" -:a:
|:@:@bad option: `-:'@|a@:@unset@|2|
:= opt ""
|1|
:: opt ""
|1|getopts_long: invalid option specification: `::'
: opt ""
|1|
:a:a opt "" -a
|:@a@option `-a' requires an argument@|2|
:a::a opt "" -a
|a@unset@unset@|2|
:ab:c:: opt "" -abc -cba -bac
|a@unset@unset@|b@c@unset@|c@ba@unset@|b@ac@unset@|4|
: opt abc 0 "" --abc
|abc@unset@unset@|2|
: opt abc no_argument "" --abc
|abc@unset@unset@|2|
: opt abc no_argument "" --abc=foo
|:@abc@option `--abc' doesn't allow an argument@|2|
: opt abc no_argument "" --abc foo
|abc@unset@unset@|2|
: opt abc 1 "" --abc=foo
|abc@foo@unset@|2|
: opt abc required_argument "" --abc foo
|abc@foo@unset@|3|
: opt abc required_argument "" --abc=
|abc@@unset@|2|
: opt abc required_argument "" --abc
|:@abc@option `--abc' requires an argument@|2|
: opt abc 2 "" --abc
|abc@unset@unset@|2|
: opt abc optional_argument "" --abc=
|abc@@unset@|2|
: opt abc optional_argument "" --abc=foo
|abc@foo@unset@|2|
: opt abc optional_argument "" --abc --abc
|abc@unset@unset@|abc@unset@unset@|3|
: opt abc 0 abcd 0 "" --abc
|abc@unset@unset@|2|
: opt abc 0 abd 0 "" --ab
|:@ab@option `--ab' is ambiguous@|2|
: opt abc 0 abcd 0 "" --ab
|:@ab@option `--ab' is ambiguous@|2|
: opt abc 0 abc 1 "" --abc
|abc@unset@unset@|2|
: opt abc 0 acd 0 "" --ab
|abc@unset@unset@|2|
:abc:d:e::f:: opt ab 0 ac 1 bc 2 cd 1 cde 2 "" -abcdef -a -f -c --a --a= --b=foo -fg
|a@unset@unset@|b@unset@unset@|c@def@unset@|a@unset@unset@|f@unset@unset@|c@--a@unset@|:@a@option `--a' is ambiguous@|bc@foo@unset@|f@g@unset@|9|
a opt "" -a
|a@unset@unset@|2|
a opt "" -a b
|a@unset@unset@|2|
a opt "" -a -a
|a@unset@unset@|a@unset@unset@|3|
a opt "" -ab
|a@unset@unset@|?@unset@bad option: `-b'@bad option: `-b'|2|
a: opt "" -ab
|a@b@unset@|2|
a: opt "" -a b
|a@b@unset@|3|
a: opt "" -a -a
|a@-a@unset@|3|
a: opt "" -a
|?@unset@option `-a' requires an argument@option `-a' requires an argument|2|
a:: opt "" -a
|a@unset@unset@|2|
a:: opt "" -ab
|a@b@unset@|2|
a:: opt "" -a b
|a@unset@unset@|2|
a:: opt "" -a -a
|a@unset@unset@|a@unset@unset@|3|
a:: opt "" -:a:
|?@unset@bad option: `-:'@bad option: `-:'|a@:@unset@|2|
= opt ""
|1|
: opt ""
|1|
'' opt ""
|1|
a:a opt "" -a
|?@unset@option `-a' requires an argument@option `-a' requires an argument|2|
a::a opt "" -a
|a@unset@unset@|2|
ab:c:: opt "" -abc -cba -bac
|a@unset@unset@|b@c@unset@|c@ba@unset@|b@ac@unset@|4|
'' opt abc 0 "" --abc
|abc@unset@unset@|2|
'' opt abc no_argument "" --abc
|abc@unset@unset@|2|
'' opt abc no_argument "" --abc=foo
|?@unset@option `--abc' doesn't allow an argument@option `--abc' doesn't allow an argument|2|
'' opt abc no_argument "" --abc foo
|abc@unset@unset@|2|
'' opt abc 1 "" --abc=foo
|abc@foo@unset@|2|
'' opt abc required_argument "" --abc foo
|abc@foo@unset@|3|
'' opt abc required_argument "" --abc=
|abc@@unset@|2|
'' opt abc required_argument "" --abc
|?@unset@option `--abc' requires an argument@option `--abc' requires an argument|2|
'' opt abc 2 "" --abc
|abc@unset@unset@|2|
'' opt abc optional_argument "" --abc=
|abc@@unset@|2|
'' opt abc optional_argument "" --abc=foo
|abc@foo@unset@|2|
'' opt abc optional_argument "" --abc --abc
|abc@unset@unset@|abc@unset@unset@|3|
'' opt abc 0 abcd 0 "" --abc
|abc@unset@unset@|2|
'' opt abc 0 abd 0 "" --ab
|?@unset@option `--ab' is ambiguous@option `--ab' is ambiguous|2|
'' opt abc 0 abcd 0 "" --ab
|?@unset@option `--ab' is ambiguous@option `--ab' is ambiguous|2|
'' opt abc 0 abc 1 "" --abc
|abc@unset@unset@|2|
'' opt abc 0 acd 0 "" --ab
|abc@unset@unset@|2|
abc:d:e::f:: opt ab 0 ac 1 bc 2 cd 1 cde 2 "" -abcdef -a -f -c --a --a= --b=foo -fg
|a@unset@unset@|b@unset@unset@|c@def@unset@|a@unset@unset@|f@unset@unset@|c@--a@unset@|?@unset@option `--a' is ambiguous@option `--a' is ambiguous|bc@foo@unset@|f@g@unset@|9|
: '' '' a
|1|getopts_long: invalid variable name: `'
: 1a ''
|1|getopts_long: invalid variable name: `1a'
- a
|1|getopts_long: invalid option specification: `-'
:a::a:abcd o ab 1 abc 1 abd 1 abe 1 abc 2 '' -aa --ab 1 --abc
|a@a@unset@|ab@1@unset@|:@abc@option `--abc' requires an argument@|5|
:
|1|getopts_long: not enough arguments
'\[$' o -- 0 ' ' 1 '#' required_argument '' '-\\\[$' --\ =a --\#=\$\$
|\@unset@unset@|\@unset@unset@|\@unset@unset@|[@unset@unset@|$@unset@unset@| @a@unset@|#@$$@unset@|4|
: o a 1 b 2 c
|1|getopts_long: long option specifications must end in an empty argument
: o a 1 b 2
|1|getopts_long: long option specifications must end in an empty argument
: o a 1 b 2 c 3 '' --c
|1|getopts_long: invalid long option type: `3'
":  " o "  " 1 '' "-  " "--  =1"
| @unset@unset@| @unset@unset@|  @1@unset@|3|
: o a 1 '' --c
|:@c@bad option: `--c'@|2|
: o a 1 '' --c=foo
|:@c@bad option: `--c'@|2|
: o ab 1 ac 1 ad 1 a 1 '' --a=1
|a@1@unset@|2|
EOF
fi
