# -*- shell-script -*-
# info.sh - gdb-like "info" debugger commands
#
#   Copyright (C) 2002, 2003, 2004, 2005, 2006, 2008, 2009,
#   2010, 2011 Rocky Bernstein <rocky@gnu.org>
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

_Dbg_help_add info ''

typeset -a _Dbg_info_subcmds
_Dbg_info_subcmds=( breakpoints display files line program source stack variables )

# Load in "info" subcommands
for _Dbg_file in ${_Dbg_libdir}/command/info_sub/*.sh ; do
    source $_Dbg_file
done
_Dbg_complete_level_1_data[info]=$(echo ${(kM)_Dbg_debugger_info_commands})

_Dbg_do_info() {

  if (($# > 0)) ; then
      typeset info_cmd=$1
      shift
      case $info_cmd in
# 	  a | ar | arg | args )
#               _Dbg_do_info_args 3
# 	      return 0
# 	      ;;
          b | br | bre | brea | 'break' | breakp | breakpo | breakpoints )
              #      b | br | bre | brea | 'break' | breakp | breakpo | breakpoints | \
              #      w | wa | wat | watc | 'watch' | watchp | watchpo | watchpoints )
              _Dbg_do_info_brkpts $@
              #	_Dbg_list_watch $@
              return 0
              ;;

          d | di | dis| disp | displ | displa | display )
              _Dbg_do_info_display $@
              return 0
              ;;

          file| files )
              _Dbg_do_info_files
              return 0
              ;;

          #       h | ha | han | hand | handl | handle | \
          #           si | sig | sign | signa | signal | signals )
          #         _Dbg_info_signals
          #         return
          # 	;;

          l | li | lin | line )
              _Dbg_do_info_line
              return $?
              ;;

          p | pr | pro | prog | progr | progra | program )
              _Dbg_do_info_program
              return $?
              ;;

          so | sou | sourc | source )
              _Dbg_do_info_source
              return 0
              ;;

          st | sta | stac | stack )
              _Dbg_do_backtrace 1 $@
              return 0
              ;;

          #       te | ter | term | termi | termin | termina | terminal | tt | tty )
          # 	_Dbg_msg "tty: $_Dbg_tty"
          # 	return;
          # 	;;

          v | va | var | vari | varia | variab | variabl | variable | variables )
              _Dbg_do_info_variables $@
              return 0
              ;;

          w | wa | war | warr | warra | warran | warrant | warranty )
              _Dbg_do_info_warranty
              return 0
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

_Dbg_alias_add 'i' info
