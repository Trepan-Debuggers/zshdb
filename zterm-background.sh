#!/usr/bin/env zsh
# ^^^^^^^^^^^^ Use env rather zsh installed somewhere

#   Copyright (C) 2019, Rocky Bernstein <rocky@gnu.org>
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

# Try to determine if we have dark or light terminal background

# This file is copied from
# https://github.com/rocky/bash-term-background If you have problems
# with this script open an issue there.  Note: I use github project
# ratings to help me determine if project issues are worth fixing when
# (as usually the case), there are several issues I could be working on.

typeset -i success=0
typeset    method="xterm control"

# On return, variable is_dark_bg is set
# We follow Emacs logic (at least initially)
get_default_bg() {
    if [[ -n $COLORFGBG ]] ; then
	method="COLORFGBG"
	is_dark_colorfgbg
    elif [[ -n $TERM ]] ; then
	case $TERM in
	    xterm-256color )
		# 382.5 = (* .6 (+ 255 255 255))
		TERMINAL_COLOR_MIDPOINT=${TERMINAL_COLOR_MIDPOINT:-383}
		;;
	    xterm* | dtterm | eterm* )
		# 117963 = (* .6 (+ 65535 65535 65535))
		TERMINAL_COLOR_MIDPOINT=${TERMINAL_COLOR_MIDPOINT:-117963}
		is_dark_bg=0
		;;

	    * )
		TERMINAL_COLOR_MIDPOINT=${TERMINAL_COLOR_MIDPOINT:-117963}
		is_dark_bg=1
		;;
	esac
    fi
}

# Pass as parameters R G B values in hex
# On return, variable is_dark_bg is set
is_dark_rgb() {
    typeset r g b
    r=$1; g=$2; b=$3
    if (( (16#$r + 16#$g + 16#$b) < $TERMINAL_COLOR_MIDPOINT )) ; then
	is_dark_bg=1
    else
	is_dark_bg=0
    fi
}

# Consult (environment) variable COLORFGB
# On return, variable is_dark_bg is set
is_dark_colorfgbg() {
    case $COLORFGBG in
	'15;0' | '15;default;0' )
	    is_dark_bg=1
	    success=1
	    ;;
	'0;15' | '0;default;15' )
	    is_dark_bg=0
	    success=1
	    ;;
	* )
	    is_dark_bg=-1
	    ;;
    esac
}

is_sourced() {
    if [[ 0 == ${#funcfiletrace[@]} ]]; then
	return 1
    else
	return 0
    fi
}

# Exit if we are not source.
# if sourced, then we just set exitrc
# which was assumed to be declared outside
exit_if_not_sourced() {
    exitrc=${1:-0}
    if ! is_sourced ; then
	exit $exitrc
    fi
}

# From:
# http://unix.stackexchange.com/questions/245378/common-environment-variable-to-set-dark-or-light-terminal-background/245381#245381
# and:
# https://bugzilla.gnome.org/show_bug.cgi?id=733423#c1
#
# User should set up RGB_fg and RGB_bg arrays
xterm_compatible_fg_bg() {
    typeset fg bg junk
    stty -echo
    # Issue command to get both foreground and
    # background color
    #            fg       bg
    echo -ne '\e]10;?\a\e]11;?\a'
    IFS=: read -t 0.1 -d $'\a' x fg
    IFS=: read -t 0.1 -d $'\a' x bg
    stty echo
    [[ -z $bg ]] && return 1
    typeset -p fg
    typeset -p bg
    IFS='/' read -ra RGB_fg <<< $fg
    IFS='/' read -ra RGB_bg <<< $bg
    typeset -p RGB_fg
    typeset -p RGB_bg
    return 0
}

# From a comment left duthen in my StackOverflow answer cited above.
osx_get_terminal_fg_bg() {
    if [[ -n $COLORFGBG ]] ; then
	method="COLORFGBG"
	is_dark_colorfgbg
    else
	RGB_bg=($(osascript -e 'tell application "Terminal" to get the background color of the current settings of the selected tab of front window'))
	# typeset -p RGB_bg
	(($? != 0)) && return 1
	TERMINAL_COLOR_MIDPOINT=117963
	is_dark_rgb ${RGB_bg[@]}
	method="OSX osascript"
	success=1
    fi
}


typeset -i success=0
typeset -i is_dark_bg=0
typeset -i exitrc=0

get_default_bg

if [[ $(uname -s) =~ darwin ]] ; then
    osx_get_terminal_fg_bg
fi

if (( !success )) && [[ -n $TERM ]] ; then
    case $TERM in
	xterm* | gnome | rxvt* )
	    typeset -a RGB_fg RGB_bg
	    if xterm_compatible_fg_bg ; then
		is_dark_rgb ${RGB_bg[@]}
		success=1
	    fi
	    ;;
	* )
	    ;;
    esac
fi

if (( success )) ; then
    if (( is_dark_bg == 1 )) ; then
	echo "Dark background from ${method}"
    else
	echo "Light background from ${method}"
    fi
elif [[ -n $COLORFGBG ]] ; then
    # Note that this can be wrong if
    # COLORFGBG was set prior invoking a terminal
    is_dark_colorfgbg
    case $is_dark_bg in
	0 )
	    echo "Light background from COLORFGBG"
	    ;;
	1 )
	    echo "Dark background from COLORFGBG"
	    ;;
	-1 | * )
	    echo "Can't decide from COLORFGBG"
	    exit_if_not_sourced 1
	    ;;
    esac
else
    echo "Can't decide"
    exit_if_not_sourced 1
fi

# If we were sourced, then set
# some environment variables
if is_sourced  ; then
    if (( exitrc == 0 )) ; then
	if (( $is_dark_bg == 1 ))  ; then
	    export DARK_BG=1
	    [[ -z $COLORFGBG ]] && export COLORFGBG='0;15'
	else
	    export DARK_BG=0
	    [[ -z $COLORFGBG ]] && export COLORFGBG='15;0'
	fi
    fi
else
    exit 0
fi
