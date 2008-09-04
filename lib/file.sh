# -*- shell-script -*-
# Things related to file handling.
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
# Directory search patch for unqualified file names

typeset -a _Dbg_dir
_Dbg_dir=('\$cdir' '\$cwd' )

# Keys are the canonic expanded filename
typeset -A _Dbg_files_seen
_Dbg_files_seen=()

# Maps a name into its canonic form which can then be looked up in files_seen
typeset -A _Dbg_file2canonic
_Dbg_file2canonic=()

# Directory in which the script is located
[[ -z ${_Dbg_cdir} ]] && [[ -n ${_Dbg_source_file} ]] && \
    _Dbg_cdir=${_Dbg_source_file%/*}

# $1 contains the name you want to glob. return 0 if exists and is
# readible or 1 if not. 
# The result will be in variable $filename which is assumed to be 
# local'd by the caller
_Dbg_glob_filename() {
  typeset cmd="filename=$(expr $1)"
  eval $cmd
  [[ -r $filename ]]
}

# Either fill out or strip filename as determined by "basename_only"
# and annotate settings
_Dbg_adjust_filename() {
  typeset -r filename="$1"
  if (( _Dbg_annotate == 1 )) ; then
    print -- $(_Dbg_resolve_expand_filename $filename)
  elif ((_Dbg_basename_only)) ; then
    print -- ${filename##*/}
  else
    print -- $filename
  fi
}

# _Dbg_is_file echoes the full filename if $1 is a filename found in files
# '' is echo'd if no file found.
function _Dbg_is_file {

  if (( $# == 0 )) ; then
    _Dbg_errmsg "Internal debug error: null file to find"
    echo ''
    return 1
  fi
  typeset find_file="$1"

  if [[ ${find_file[0]} == '/' ]] ; then 
      # Absolute file name
      # FIXME: turn into common subroutine
      for try_file in ${_Dbg_filenames[@]} ; do 
	  if [[ $try_file == $find_file ]] ; then
	      echo "$try_file"
	      return
	  fi
      done
  elif [[ ${find_file[0]} == '.' ]] ; then
      # Relative file name
      find_file=$(_Dbg_expand_filename ${_Dbg_init_cwd}/$find_file)
      # FIXME: turn into common subroutine
      for try_file in ${_Dbg_filenames[@]} ; do 
	  if [[ $try_file == $find_file ]] ; then
	      echo "$try_file"
	      return
	  fi
      done
  else
    # Resolve file using _Dbg_dir
    for try_file in ${_Dbg_filenames[@]} ; do 
      typeset pathname
      typeset -i n=${#_Dbg_dir[@]}
      typeset -i i
      for (( i=0 ; i < n; i++ )) ; do
	typeset basename="${_Dbg_dir[i]}"
	if [[  $basename = '\$cdir' ]] ; then
	  basename=$_Dbg_cdir
	elif [[ $basename = '\$cwd' ]] ; then
	  basename=$(pwd)
	fi
	if [[ "$basename/$find_file" == $try_file ]] ; then
	  echo "$try_file"
	  return
	fi
      done
    done
  fi
  echo ''
}

#
# Resolve $1 to a full file name which exists. First see if filename has been
# mentioned in a debugger "file" command. If not and the file name
# is a relative name use _Dbg_dir to substitute a relative directory name.
#
function _Dbg_resolve_expand_filename {

  if (( $# == 0 )) ; then
    _Dbg_errmsg "Internal debug error: null file to find"
    echo ''
    return 1
  fi
  typeset find_file="$1"

  # Is this one of the files we've that has been specified in a debugger
  # "FILE" command?
  typeset found_file
  found_file="${_Dbg_files_seen[$file_cmd_file]}"
  if [[ -n  $found_file ]] ; then
    print -- "$found_file"
    return 0
  fi

  if [[ ${find_file[0]} == '/' ]] ; then 
    # Absolute file name
    print -- "$find_file"
    return 0
  elif [[ ${find_file[0]} == '.' ]] ; then
    # Relative file name
    full_find_file=$(_Dbg_expand_filename ${_Dbg_init_cwd}/$find_file)
    if [[ -z "$full_find_file" ]] || [[ ! -r $full_find_file ]]; then
      # Try using cwd rather that Dbg_init_cwd
      full_find_file=$(_Dbg_expand_filename $find_file)
    fi
    print -- "$full_find_file"
    return 0
  else
    # Resolve file using _Dbg_dir
    typeset -i n=${#_Dbg_dir[@]}
    typeset -i i
    for (( i=0 ; i < n; i++ )) ; do
      typeset basename="${_Dbg_dir[i]}"
      if [[  $basename == '\$cdir' ]] ; then
	basename=$_Dbg_cdir
      elif [[ $basename == '\$cwd' ]] ; then
	basename=$(pwd)
      fi
      if [[ -f "$basename/$find_file" ]] ; then
	echo "$basename/$find_file"
	return 0
      fi
    done
  fi
  echo ''
  return 1
}

# Check that line $2 is not greater than the number of lines in 
# file $1
_Dbg_check_line() {
  typeset -i line_number=$1
  typeset filename=$2
#   typeset -i max_line=$(_Dbg_get_maxline $filename)
#   if (( $line_number >  max_line )) ; then 
#     (( _Dbg_basename_only )) && filename=${filename##*/}
#     _Dbg_err_msg "Line $line_number is too large." \
#       "File $filename has only $max_line lines."
#     return 1
#   fi
  return 0
}
