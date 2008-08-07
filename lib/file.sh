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

# Directory in which the script is located
## [[ -z _Dbg_cdir ]] && typeset -r _Dbg_cdir=${_Dbg_source_file%/*}

# $1 contains the name you want to glob. return 1 if exists and is
# readible or 0 if not. 
# The result will be in variable $filename which is assumed to be 
# local'd by the caller
_Dbg_glob_filename() {
  typeset cmd="filename=$(expr $1)"
  eval $cmd
}

