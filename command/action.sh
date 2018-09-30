# -*- shell-script -*-
# action.sh - Perldb's "action" debugger command
#
#   Copyright (C) 2010-2011, 2016, 2018 Rocky Bernstein
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

_Dbg_help_add action \
'**action** *linespec* *command*

Run *command* when *linespec* is hit

Use "A" to remove all actions and "L" to get a list of the actions in
effect.'

# Add action at given line number of the current file.  $1 is the
# line number or _Dbg_frame_last_lineno if omitted.  $2 is a
# condition to test for whether to stop.
_Dbg_do_action() {

  if (( $# == 0 )) ; then
      _Dbg_list_action
      return 0
  fi
  if (( $# == 1 )) ; then
      typeset n=$_Dbg_frame_last_lineno
  else
      typeset n=$1
      shift
  fi

  typeset stmt="$*"

  typeset filename
  typeset -i line_number
  typeset full_filename

  _Dbg_linespec_setup $n

  if [[ -n "$full_filename" ]] ; then
      if (( line_number ==  0 )) ; then
          _Dbg_msg "There is no line 0 to set action at."
      else
          _Dbg_check_line $line_number "$full_filename"
          (( $? == 0 )) && \
              _Dbg_set_action "$full_filename" "$line_number" "$stmt"
      fi
  else
      _Dbg_file_not_read_in "$filename"
  fi
  return 0
}

_Dbg_alias_add 'a' 'action'

# delete action at given file:line number. If no file is given use the
# current file. 0 is returned on success, nonzero on error.
_Dbg_do_clear_action() {
    (( $# > 1 )) && return 1
    typeset -r n=${1:-$_Dbg_frame_last_lineno}

    typeset filename
    typeset -i line_number
    typeset full_filename

    _Dbg_linespec_setup $n

    if [[ -n $full_filename ]] ; then
        if (( line_number ==  0 )) ; then
            _Dbg_msg "There is no line 0 to clear action at."
        else
            _Dbg_check_line $line_number "$full_filename"
            (( $? == 0 )) && \
                _Dbg_unset_action "$full_filename" "$line_number"
            if [[ $? == 0 ]] ; then
                _Dbg_msg "Removed action."
                return 0
            else
                _Dbg_errmsg "Didn't find any actions to remove at $n."
            fi
        fi
    else
        _Dbg_file_not_read_in $filename
    fi
    return 1
}

# Routine to a delete actions by entry numbers.
_Dbg_do_action_delete() {
  typeset -r  to_go=$@
  typeset -i  i
  typeset -i  found=0

  for del in $to_go ; do
    case $del in
        [0-9]* )
            _Dbg_delete_action_entry $del
            ((found += $?))
            ;;
        * )
            _Dbg_msg "Invalid entry number skipped: $del"
    esac
  done
  [[ $found != 0 ]] && _Dbg_msg "Removed $found action(s)."
  return $found
}

# delete action at given file:line number. If no file is given
# use the current file. 0 is returned on success, nonzero on error.
_Dbg_do_clear_action() {
    (( $# > 1 )) && return 1
    typeset -r n=${1:-$_Dbg_frame_last_lineno}

    typeset filename
    typeset -i line_number
    typeset full_filename

    _Dbg_linespec_setup $n

    if [[ -n $full_filename ]] ; then
        if (( line_number ==  0 )) ; then
            _Dbg_msg "There is no line 0 to clear action at."
        else
            _Dbg_check_line $line_number "$full_filename"
            (( $? == 0 )) && \
                _Dbg_unset_action "$full_filename" "$line_number"
            if [[ $? == 0 ]] ; then
                _Dbg_msg "Removed action."
                return 0
            else
                _Dbg_errmsg "Didn't find any actions to remove at $n."
            fi
        fi
    else
        _Dbg_file_not_read_in $filename
    fi
    return 1
}

# clear all actions
_Dbg_do_clear_all_actions() {
    (( $# != 0 )) && return 1

    if ((_Dbg_action_count == 0)); then
        _Dbg_errmsg "No actions to delete."
        return 1
    fi

    typeset -l _Dbg_response
    _Dbg_confirm "Delete all actions? (y/N): " 'N'

    if [[ $_Dbg_response != 'y' ]] ; then
        _Dbg_msg "Delete not done - not confirmed."
        return 1
    fi

    _Dbg_write_journal_eval "_Dbg_action_count=0"
    _Dbg_write_journal_eval "_Dbg_action_enable=()"
    _Dbg_write_journal_eval "_Dbg_action_line=()"
    _Dbg_write_journal_eval "_Dbg_action_file=()"
    _Dbg_write_journal_eval "_Dbg_action_stmt=()"
    _Dbg_write_journal_eval "_Dbg_action_file2action=()"
    _Dbg_write_journal_eval "_Dbg_action_file2linenos=()"
    return 0
}
