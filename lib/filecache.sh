# -*- shell-script -*-
# filecache.sh - cache file information
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

# Keys are the canonic expanded filename. _Dbg_filenames[filename] is
# name of variable which contains text.
typeset -A _Dbg_filenames
_Dbg_filenames=()

# Maps a name into its canonic form which can then be looked up in filenames
typeset -A _Dbg_file2canonic
_Dbg_file2canonic=()

# Information about a file.
typeset -A _Dbg_fileinfo
_Dbg_fileinfo=()

# Read $1 into _DBG_source_*n* array where *n* is an entry in
# _Dbg_filenames.  Variable _Dbg_seen[canonic-name] will be set to
# note the file has been read and the filename will be saved in array
# _Dbg_filenames

function _Dbg_readin {
    typeset filename
    if (($# != 0)) ; then 
	filename="$1"
    else
	_Dbg_frame_file
	filename="$_Dbg_frame_filename"
    fi

    typeset -i line_count=0
    typeset -ir NOT_SMALLFILE=1000

    typeset -i next;
    next=${#_Dbg_filenames[@]}
    typeset source_array_var;
    source_array_var="_Dbg_source_${next}"

    if [[ -z $filename ]] || [[ $filename == _Dbg_bogus_file ]] ; then 
	eval "typeset -a $source_array_var; ${source_array_var}=()"
	typeset cmd="${source_array_var}[0]=\"$BASH_EXECUTION_STRING\""
	eval $cmd
    else 
	typeset fullname=$(_Dbg_resolve_expand_filename $filename)
	if [[ -r $fullname ]] ; then
	    _Dbg_file2canonic[$filename]="$fullname"
	    eval "typeset -a $source_array_var; ${source_array_var}=()"
	    typeset -r progress_prefix="Reading $filename"
	    # No readarray. Do things the long way.
	    typeset -i i=-1
	    typeset -i fd
# 	    exec {fd} < $fullname
# 	    while read line <&${fd}
# 	    do
# 		((i++))
# 		typeset assign_cmd="${source_array_var}[$i]=\"$line\""
# 		eval $assign_cmd
# 		if (( i % 1000 == 0 )) ; then
# 		    if (( i==NOT_SMALLFILE )) ; then
# 			if wc -l < /dev/null >/dev/null 2>&1 ; then 
# 			    line_count=$(wc -l < "${fullname}")
# 			else
# 			    _Dbg_msg_nocr "${progress_prefix} "
# 			fi
# 		    fi
# 		    if (( line_count == 0 )) ; then
# 			_Dbg_msg_nocr "${i}... "
# 		    else
# 			_Dbg_progess_show "${progress_prefix}" ${line_count} ${i}
# 		    fi
# 		fi
# 	    done
# 	    (( line_count != 0 )) && _Dbg_progess_done
	else
	    return 1
	fi
    fi
    
#    (( i >= NOT_SMALLFILE )) && _Dbg_msg "done."
    
    # Save info about file: # lines, checksum and date.
    ## 
    
    # Add $filename to list of all filenames
    _Dbg_filenames[$fullname]=$source_array_var;
    return 0
}


# _Dbg_is_file echoes the full filename if $1 is a filename found in files
# '' is echo'd if no file found. Return 0 (in $?) if found, 1 if not.
function _Dbg_is_file {
  if (( $# == 0 )) ; then
    _Dbg_errmsg "Internal debug error: null file to find"
    echo ''
    return 1
  fi
  typeset find_file="$1"

  if [[ ${find_file[0]} == '/' ]] ; then 
      # Absolute file name
      if [[ -n ${_Dbg_filenames[$find_file]} ]] ; then
	  print -- "$find_file"
	  return 0
      fi
  elif [[ ${find_file[0]} == '.' ]] ; then
      # Relative file name
      try_find_file=$(_Dbg_expand_filename ${_Dbg_init_cwd}/$find_file)
      # FIXME: turn into common subroutine
      if [[ -n ${_Dbg_filenames[$try_find_file]} ]] ; then
	  print -- "$try_find_file"
	  return 0
      fi
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
      try_find_file="$basename/$find_file"
      if [[ -f "$try_find_file" ]] ; then
	  print -- "$try_find_file"
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
