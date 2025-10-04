#!/usr/bin/env zsh
# ^^^^^^^^^^^^ Use env rather zsh installed somewhere

#   Copyright (C) 2019-2020, 2024, 2025 Rocky Bernstein <rocky@gnu.org>
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

# Try to determine if we have dark or light terminal background.

# This file is resides in, or is copied from, the project:
#    https://github.com/rocky/shell-term-background
#
# If you have problems with this script open an issue there.  Note: I
# use github project ratings to help me determine if project issues
# are worth fixing when (as usually the case), there are several
# issues I could be working on.

typeset method="xterm control"

# "0" is the black in the standard 16-color ANSI pallet.
# "15" is white in the standard 16-color ANSI pallet.
# ";" separates the foreground and background color.
#
# So COLORFGBG="0;15" indicates a white background
# with black foreground text, or a light background.

WHITE_BACKGROUND_FGBG="0;15"
BLACK_BACKGROUND_FGBG="15;0"

# On return, variable is_dark_bg is set
# We follow Emacs logic (at least initially)
get_default_colorfgbg() {
  if [[ -n $COLORFGBG ]]; then
    method="COLORFGBG"
    is_dark_colorfgbg
  elif [[ -n $TERM ]]; then
    case $TERM in
    xterm-256color)
      # 382.5 = (* .6 (+ 255 255 255))
      TERMINAL_COLOR_MIDPOINT=${TERMINAL_COLOR_MIDPOINT:-383}
      ;;
    xterm* | dtterm | eterm*)
      # 117963 = (* .6 (+ 65535 65535 65535))
      TERMINAL_COLOR_MIDPOINT=${TERMINAL_COLOR_MIDPOINT:-117963}
      is_dark_bg=0
      ;;

    *)
      TERMINAL_COLOR_MIDPOINT=${TERMINAL_COLOR_MIDPOINT:-117963}
      is_dark_bg=1
      ;;
    esac
  fi
}

# Pass as parameters R, G, and B values.
# In some terminals the value is in hex and in some terminals it is in decimal.
# Compare FG to BG for light/dark, not just FG and midpoint
# NOTE: We could have FG=#403020 BG=#403040 and tie
# On return, variable is_dark_bg is set
is_dark_rgb() {
  typeset fg_r fg_g fg_b
  typeset bg_r bg_g bg_b
  typeset a_fg a_bg
  fg_r=${1:-0}
  fg_g=${2:-0}
  fg_b=${3:-0}
  bg_r=${4:-255}
  bg_g=${5:-255}
  bg_b=${6:-255}

  # Check if any of the R, G, or B values contain hex letters.
  # If so, convert to decimal.
  if [[ "$fg_r" =~ [a-fA-F] || "$fg_g" =~ [a-fA-F] || "$fg_b" =~ [a-fA-F] ]]; then
    a_fg=$((16#"$fg_r" + 16#"$fg_g" + 16#"$fg_b"))
    a_bg=$((16#"$bg_r" + 16#"$bg_g" + 16#"$bg_b"))
  else
    a_fg=$((fg_r + fg_g + fg_b))
    a_bg=$((bg_r + bg_g + bg_b))
  fi

  if [[ $a_fg -gt $a_bg ]]; then
    is_dark_bg=1
  else
    is_dark_bg=0
  fi
}

# NOTE: We could have FG=#403020 BG=#403040 and tie
# On return, variable is_dark_bg is set
is_dark_rgb_from_bg() {
  midpoint=32767
  bg_r=${1%,}
  bg_g=${2%,}
  bg_b=${3%,}
  typeset -i a_bg=$((bg_r + bg_g + bg_b))
  if (( $a_bg < $midpoint )); then
    is_dark_bg=1
  else
    is_dark_bg=0
  fi
}

# Consult (environment) variable CLITHEME.
# See: https://wiki.tau.garden/cli-theme.
#
# On return, variable "is_dark_bg" is set,
# and "success" can be changed from "0" to
# "1".
#
is_dark_clitheme() {
  case $CLITHEME in
  "light" | "light:*")
    is_dark_bg=0
    success=1
    ;;
  "dark" | "dark:*")
    is_dark_bg=1
    success=1
    ;;
  "auto" | "auto:*")
    ;;
  *)
    is_dark_bg=-1
    ;;
  esac
}

# Consult (environment) variable COLORFGBG.
# On return, variable "is_dark_bg" is set,
# and "success" can be changed from "0" to
# "1".
#
is_dark_colorfgbg() {
  case $COLORFGBG in
  ${WHITE_BACKGROUND_FGBG} | '0;default;15')
    is_dark_bg=0
    success=1
    ;;
  ${BLACK_BACKGROUND_FGBG} | '15;default;0')
    is_dark_bg=1
    success=1
    ;;
  *)
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
  if ! is_sourced; then
    exit "$exitrc"
  fi
}

# Light and Dark Mode detection using Control Sequence Introducer (CSI)
# CSI ?996 will indicate whether a terminal is in a light or dark theme.
# See https://contour-terminal.org/vt-extensions/color-palette-update-notifications/
#
# On a successful return, "is_dark_bg" is set to "1" or "0", and "1" is returned.
# On failure, "is_dark_bg" is unchanged and "0" is returned.
csc_compatible_fg_bg() {
  typeset theme_mode_indicator
  # Turn TTY off
  stty -echo 2>/dev/null

  # Issue CSI (Operating System Command) "996n" to get light-or-dark style.
  echo -ne '\e[?996n\a'

  # Read back in terminal program reporting its CSI 996 value.
  IFS=: read -t 0.1 -d $'\a' term_mode_indicator

  # Turn TTY back on [
  stty echo 2>/dev/null

  [[ -z $theme_mode_indicator ]] && return 1

  # Convert to array
  case $theme_mode_indicator in
       "997;1n" )
	 # Dark mode
	 contour_osc_done=1
	 is_dark_bg=1
	 return 1
	 ;;
       '997;2n' )
	 # Light mode
	 contour_osc_done=1
	 is_dark_bg=0
	 return 1
	 ;;
       *)
	 # Unkonwn
	 ;;
  esac
  contour_osc_done=1
  return 0
}


# From:
# http://unix.stackexchange.com/questions/245378/common-environment-variable-to-set-dark-or-light-terminal-background/245381#245381
# and:
# https://bugzilla.gnome.org/show_bug.cgi?id=733423#c1
#
# User should set up RGB_fg and RGB_bg arrays
xterm_compatible_fg_bg() {
  typeset fg bg
  # Turn TTY off
  stty -echo 2>/dev/null

  # Issue OSC (Operating System Command) to get foreground.
  # OSC is described in https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands.
  echo -ne '\e]10;?\a'

  # Read back in terminal program reporting its OSC fg values.
  IFS=: read -t 0.1 -d $'\a' x fg

  # Turn TTY back on
  stty echo 2>/dev/null

  # Remove any escape or control characters.
  # Note: gnome-terminal tacked \e at end
  fg="${fg//[^a-zA-Z0-9\/]/}"
  [[ -z $fg ]] && return 1

  # Convert to array
  IFS='/' read -ra RGB_fg <<<"$fg"

  if [[ -n $DEBUG_TERM_BACKGROUND ]]; then
    typeset -p fg
    typeset -p RGB_fg
  fi

  # Turn TTY off
  stty -echo 2>/dev/null

  # Issue command to get background.
  echo -ne '\e]11;?\a'

  # Read back in terminal program reporting its OSC bg values
  # purposely reading x, then discarding it.

  IFS=: read -t 0.1 -d $'\a' x bg

  # Turn TTY back on
  stty echo 2>/dev/null

  # Remove any escape or control characters.
  # Note: gnome-terminal tacked \e at end
  bg="${bg//[^a-zA-Z0-9\/]/}"
  [[ -z $bg ]] && return 1

  # Convert to array
  IFS='/' read -ra RGB_bg <<<"$bg"

  if [[ -n $DEBUG_TERM_BACKGROUND ]]; then
    typeset -p bg
    typeset -p RGB_bg
  fi

  xterm_osc_done=1
  return 0
}

osx_get_terminal_fg_bg() {
    if [[ -n $CLITHEME ]] ; then
	method="CLITHEME"
	is_dark_clitheme
    fi
    if ((success == 0)) && [[ -n $COLORFGBG ]]; then
	method="COLORFGBG"
	is_dark_colorfgbg
    else
	# From a comment left by user "duthen" in my StackOverflow answer cited above.
	# shellcheck disable=SC2207
	RGB_bg=($(osascript -e 'tell application "Terminal" to get the background color of the current settings of the selected tab of front window'))
	retsts=$?
	# typeset -p RGB_bg
	((retsts != 0)) && return 1
	is_dark_rgb_from_bg "${RGB_bg[@]}"
	method="OSX osascript"
	success=1
    fi
}

typeset -i success=0
typeset -i is_dark_bg=0
typeset -i exitrc=0
typeset -i contour_csi_done=0
typeset -i xterm_osc_done=0

# if [[ -n $COLORTERM ]] && [[ $COLORTERM == "truecolor" ]]; then
#   # Try to get light/dark mode using CSC 996 command
#   csc_compatible_fg_bg
# fi

# Pre-analysis for non-COLORFGBG terminals
if ((!success)) && (( 3711 < VTE_VERSION )) && [[ -z "$COLORFGBG" ]]; then
  # Try Xterm Operating System Command (OSC) (Esc-])
  if xterm_compatible_fg_bg; then
    is_dark_rgb "${RGB_fg[@]}" "${RGB_bg[@]}"
    if [[ $is_dark_bg == 1 ]]; then
      # Even though, we're xterm, assist COLORFGBG
      export COLORFGBG=${WHITE_BACKGROUND_FGBG}
    else
      # Even though, we're xterm, assist COLORFGBG
      export COLORFGBG=${BLACK_BACKGROUND_FGBG}
    fi
  else
    echo "xterm/vte Esc-] OSC has empty string"
    get_default_colorfgbg
  fi
  unset x fg bg avg_RGB_fg avg_RGB_bg
fi

if ((!success)) && [[ $(uname -s) =~ [dD]arwin ]] ; then
    osx_get_terminal_fg_bg
fi

if ((!success)); then
    if [[ -n $TERM ]]; then
	case $TERM in
	    xterm* | gnome | rxvt* | linux | contour )
		typeset -a RGB_fg RGB_bg
		# if [[ $xterm_osc_done -eq 0 ]]; then
		#     if xterm_compatible_fg_bg; then
		# 	is_dark_rgb "${RGB_fg[@]}" "${RGB_bg[@]}"
		#     fi
		#     success=1
		# fi
		;;
	    *) ;;
	esac
    fi
fi

if ((success)); then
  if ((is_dark_bg == 1)); then
    echo "Dark background from ${method}"
  else
    echo "Light background from ${method}"
  fi
elif [[ -n $COLORFGBG ]]; then
  # Note that this can be wrong if
  # COLORFGBG was set prior invoking a terminal
  is_dark_colorfgbg
  case $is_dark_bg in
  0)
    echo "Light background from COLORFGBG"
    ;;
  1)
    echo "Dark background from COLORFGBG"
    ;;
  -1 | *)
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
if is_sourced; then
  if ((exitrc == 0)); then
    if ((is_dark_bg == 1)); then
      export DARK_BG=1 # deprecated
      export LC_DARK_BG=1
      if [[ -z "$COLORFGBG" ]]; then
	  export COLORFGBG=${WHITE_BACKGROUND_FGBG}
      fi
    else
      export DARK_BG=0
      export LC_DARK_BG=0
      if [[ -z "$COLORFGBG" ]] ; then
	  export COLORFGBG=${BLACK_BACKGROUND_FGBG}
      fi
    fi
  fi
else
  exit 0
fi
