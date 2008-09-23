# -*- shell-script -*-
# info.sh - gdb-like "info" debugger commands
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

# Print info args. Like GDB's "info args"
# $1 is an additional offset correction - this routine is called from two
# different places and one routine has one more additional call on top.
# This code assumes the's debugger version of
# bash where FUNCNAME is an array, not a variable.

_Dbg_help_add info ''

typeset -a _Dbg_info_subcmds
_Dbg_info_subcmds=( breakpoints files line program source stack variables )
_Dbg_do_info() {
      
  if (($# > 0)) ; then
      typeset info_cmd=$1
      shift
      case $info_cmd in 
	  a | ar | arg | args )
              _Dbg_do_info_args 3  # located in dbg-stack.sh
	      return 0
	      ;;
	  b | br | bre | brea | 'break' | breakp | breakpo | breakpoints )
	      #      b | br | bre | brea | 'break' | breakp | breakpo | breakpoints | \
	      #      w | wa | wat | watc | 'watch' | watchp | watchpo | watchpoints )
	      _Dbg_do_list_brkpt $*
	      #	_Dbg_list_watch $*
	      return 0
	      ;;
	  
	  #       d | di | dis| disp | displ | displa | display )
	  # 	_Dbg_do_list_display $*
	  # 	return
	  # 	;;
	  
          file| files )
              _Dbg_msg "Source files which we have recorded info about:"
	      unsetopt ksharrays
	      for file in ${(ki)_Dbg_file2canonic} ; do
		  typeset -i lines=$(_Dbg_get_maxline $file)
		  _Dbg_msg "  ${file}: ${_Dbg_file2canonic[$file]}, $lines lines"
	      done
	      setopt ksharrays
              return 0
	      ;;
	  
	  #       h | ha | han | hand | handl | handle | \
	  #           si | sig | sign | signa | signal | signals )
	  #         _Dbg_info_signals
	  #         return
	  # 	;;
	  
	  l | li | lin | line )
              if (( ! _Dbg_running )) ; then
		  _Dbg_errmsg 'No line number information available.'
		  return 1
	      fi
	      
              _Dbg_msg "Line $_Dbg_frame_last_lineno of \"$_Dbg_frame_last_filename\""
	      return 0
	      ;;
	  
	  p | pr | pro | prog | progr | progra | program )
	      if (( _Dbg_running )) ; then
		  _Dbg_msg 'Program stopped.'
		  if (( _Dbg_currentbp )) ; then
		      _Dbg_msg "It stopped at breakpoint ${_Dbg_currentbp}."
		  elif [[ -n $_Dbg_stop_reason ]] ; then
		      _Dbg_msg "It stopped ${_Dbg_stop_reason}."
		  fi
	      else
		  _Dbg_errmsg 'The program being debugged is not being run.'
		  return 1
	      fi
	      return 0
	      ;;
	  
	  so | sou | sourc | source )
              _Dbg_msg "Current script file is $_Dbg_frame_last_filename" 
              _Dbg_msg "Located in ${_Dbg_file2canonic[$_Dbg_frame_last_filename]}" 
	      typeset -i max_line
	      max_line=$(_Dbg_get_maxline $_Dbg_frame_last_filename)
	      _Dbg_msg "Contains $max_line lines."
              return 0
	      ;;
	  
	  st | sta | stac | stack )
	      _Dbg_do_backtrace 1 $*
	      return $?
	      ;;
	  
	  #       te | ter | term | termi | termin | termina | terminal | tt | tty )
	  # 	_Dbg_msg "tty: $_Dbg_tty"
	  # 	return;
	  # 	;;
	  
	  v | va | var | vari | varia | variab | variabl | variable | variables )
	      _Dbg_do_info_variables $*
	      return $?
	      ;;
	  
	  w | wa | war | warr | warra | warran | warrant | warranty )
	      _Dbg_do_info_warranty
	      return $?
	      ;;
	  *)
	      _Dbg_errmsg "Unknown info subcommand: $info_cmd"
	      msg=_Dbg_errmsg
      esac
  else
      msg=_Dbg_msg
  fi
  $msg "Info subcommands are:"
  typeset -a list; list=(${_Dbg_info_subcmds[@]})
  _Dbg_list_columns '  ' $msg
  return 1
}

_Dbg_do_info_variables() {
    typeset attrs="array, export, fixed, float, function, hash, integer, or readonly"
    if (($# > 0)) ; then
	typeset kind="$1"
	shift
	case "$kind" in
	    a | ar | arr | arra | array )
		_Dbg_do_list_typeset_attr '+a' $*
		return 0
		;;
	    e | ex | exp | expor | export )
		_Dbg_do_list_typeset_attr '+x' $*
		return 0
		;;
	    fu|fun|func|funct|functi|functio|function )
		_Dbg_do_list_typeset_attr '+f' $*
		return 0
		;;
	    fi|fix|fixe|fixed )
		_Dbg_do_list_typeset_attr '+F' $*
		return 0
		;;
	    fl|flo|floa|float )
		_Dbg_do_list_typeset_attr '+E' $*
		return 0
		;;
# 	    g | gl | glo | glob | globa | global )
# 		_Dbg_do_list_globals
# 		return 0
# 		;;
	    h | ha | has | hash )
		_Dbg_do_list_typeset_attr '+A' $*
		return 0
		;;
	    i | in | int| inte | integ | intege | integer )
		_Dbg_do_list_typeset_attr '+i' $*
		return 0
		;;
# 	    l | lo | loc | loca | local | locals )
# 		_Dbg_do_list_locals
# 		return 0
# 		;;
	    r | re | rea| read | reado | readon | readonl | readonly )
		_Dbg_do_list_typeset_attr '+r' $*
		return 0
		;;
	    * )
		_Dbg_errmsg "Don't know how to list variable type: $kind"
	esac
    fi
    _Dbg_errmsg "Need to specify a variable class which is one of: "
    _Dbg_errmsg "\t$attrs"
    return 1
}

_Dbg_do_info_warranty() {
    _Dbg_msg "
			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.
"
    return 0
}

# _Dbg_do_info_args() {

#   typeset -i n=${#FUNCNAME[@]}-1  # remove us (_Dbg_do_info_args) from count

#   eval "$_seteglob"
#   if [[ $1 != $int_pat ]] ; then 
#     _Dbg_msg "Bad integer parameter: $1"
#     eval "$_resteglob"
#     return 1
#   fi

#   typeset -i i=_Dbg_stack_pos+$1

#   (( i > n )) && return 1

#   # Figure out which index in BASH_ARGV is position "i" (the place where
#   # we start our stack trace from). variable "r" will be that place.

#   typeset -i q
#   typeset -i r=0
#   for (( q=0 ; q<i ; q++ )) ; do 
#     (( r = r + ${BASH_ARGC[$q]} ))
#   done

#   # Print out parameter list.
#   if (( 0 != ${#BASH_ARGC[@]} )) ; then

#     typeset -i arg_count=${BASH_ARGC[$i]}

#     ((r += arg_count - 1))

#     typeset -i s
#     for (( s=1; s <= arg_count ; s++ )) ; do 
#       _Dbg_printf "$%d = %s" $s "${BASH_ARGV[$r]}"
#       ((r--))
#     done
#   fi
#   return 0
# }

_Dbg_alias_add 'i' info
