# -*- shell-script -*-
#
#   Copyright (C) 2008-2011, 2016, 2018 Rocky Bernstein
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

_Dbg_help_add break \
'**break** [*loc-spec*]

Set a breakpoint at *loc-spec*.

If no location specification is given, use the current line.

Multiple breakpoints at one place are permitted, and useful if conditional.

See also:
---------

"tbreak" and "continue"'

_Dbg_help_add tbreak \
'**tbreak* [*loc-spec*]

Set a one-time breakpoint at *loc-spec*.

Like "break" except the breakpoint is only temporary,
so it will be deleted when hit.  Equivalent to "break" followed
by using "delete" on the breakpoint number.

If no location specification is given, use the current line.'

_Dbg_do_tbreak() {
    _Dbg_do_break_common 1 $@
    return $?
}

_Dbg_do_break() {
    _Dbg_do_break_common 0 $@
    return $?
}

# Add breakpoint(s) at given line number of the current file.  $1 is
# the line number or _Dbg_frame_lineno if omitted.  $2 is a condition
# to test for whether to stop.
_Dbg_do_break_common() {

  typeset -i is_temp=$1
  (( $# > 0 )) && shift

  typeset linespec
  if (( $# > 0 )) ; then
      linespec="$1"
  else
      _Dbg_frame_lineno; linespec=$_Dbg_frame_lineno
  fi
  (( $# > 0 )) && shift

  typeset condition=${1:-''}
  if [[ "$linespec" == 'if' ]]; then
    _Dbg_frame_lineno; linespec=$_Dbg_frame_lineno
  elif [[ -z $condition ]] ; then
    condition=1
  elif [[ $condition == 'if' ]] ; then
    shift
    condition="$@"
  fi
  [[ -z $condition ]] && condition=1

  typeset filename
  typeset -i line_number
  typeset full_filename

  _Dbg_linespec_setup "$linespec"

  if [[ -n "$full_filename" ]]  ; then
    if (( line_number ==  0 )) ; then
      _Dbg_errmsg 'There is no line 0 to break at.'
      return
    else
      _Dbg_check_line $line_number "$full_filename"
      (( $? == 0 )) && \
        _Dbg_set_brkpt "$full_filename" "$line_number" $is_temp "$condition"
    fi
  else
    _Dbg_file_not_read_in "$filename"
  fi
  _Dbg_last_cmd="break"
}

# delete brkpt(s) at given file:line numbers. If no file is given
# use the current file.
_Dbg_do_clear_brkpt() {
  typeset -r n=${1:-$_Dbg_frame_last_lineno}

  typeset filename
  typeset -i line_number
  typeset full_filename

  if [[ -n $full_filename ]] ; then
    if (( line_number ==  0 )) ; then
      _Dbg_msg "There is no line 0 to clear."
    else
      _Dbg_check_line $line_number "$full_filename"
      if (( $? == 0 )) ; then
        _Dbg_unset_brkpt "$full_filename" "$line_number"
        typeset -r found=$?
        if [[ $found != 0 ]] ; then
          _Dbg_msg "Removed $found breakpoint(s)."
        else
          _Dbg_msg "Didn't find any breakpoints to remove at $n."
        fi
      fi
    fi
  else
    _Dbg_file_not_read_in "$filename"
  fi
}

_Dbg_alias_add b break
