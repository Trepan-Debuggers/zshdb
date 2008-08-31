# -*- shell-script -*-
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
#
#  Code ported from my Ruby code which is in turn ported from a routine
#  from Python.

# columnize a blank-delmited string $1 with maximum column width $2,
# separate columns with $3. The column width defaults to 80 and the
# column separator is two spaces.  However if we are using ksh93t or
# greater, then $1 is where the return value is to go and the other
# parameters are shifted by 1: $2 contains the list to columnize and
# $3 the maximum width, etc.
columnize() {
    typeset -a list
    eval "list=($1)"
    typeset -i displaywidth=${2:-80}
    typeset colsep=${3:-'  '}
    typeset -i list_size=${#list[@]}
    if ((list_size == 0)) ; then
      columnized=('<empty>')
      return
    fi
    if ((1 == list_size)); then
	columnized=("${list[0]}")
	return 
    fi
    # Consider arranging list in 1 rows total, then 2 rows...
    # Stop when at the smallest number of rows which
    # can be arranged less than the display width.
    typeset -i nrows=0 
    typeset -i ncols=0
    typeset -i i=0
    for (( i=0; i<list_size; i++ )) ; do 
      typeset -a colwidths
      colwidths=()
      ((nrows++))
      
      ((ncols=(list_size + nrows-1) / nrows))
      typeset -i totwidth=-${#colsep}
      typeset -i col
      for (( col=0; col<=(ncols-1); col++ )); do
          # get max column width for this column
          colwidth=0
	  typeset -i row
          for (( row=0; row<=(nrows-1); row++ )); do
              ((i=row + nrows*col))  # [rows, cols]
              if ((i >= list_size)); then
		  break
	      fi
	      typeset item=${list[i]}
	      ((colwidth < ${#item})) && colwidth=${#item}
          done
          colwidths+=($colwidth)
          ((totwidth+=colwidth + ${#colsep}))
          if ((totwidth > displaywidth)); then
              break
          fi
      done
      if ((totwidth <= displaywidth)); then
          break
      fi
    done
    # The smallest number of rows computed and the
    # max widths for each column has been obtained.
    # Now we just have to format each of the
    # rows.
    columnized=()
    for (( row=0; row<nrows; row++ )); do
	typeset -i text_size=0
	typeset -a texts
	texts=()
	for ((col=0; col<ncols; col++)); do
	    ((i=row + nrows*col))
            if ((i >= list_size)); then
		item=''
            else
		item=${list[i]}
	    fi
	    
	    texts[$text_size]="$item"
	    ((text_size++))
	done
	while (( text_size > 0 )) && [[ ${texts[$text_size-1]} == '' ]] ; do 
	    ((text_size--))
	    ((text_size == ${#texts[@]})) &&  unset texts[$text_size]
	done
	text_row=''
	text_cell=''
	for (( col=0; col<text_size; col++ )); do
	    fmt="%-${colwidths[col]}s"
	    text_cell=$(printf $fmt ${texts[col]})
	    text_row+="${text_cell}"
	    ((col != text_size-1)) && text_row+="${colsep}"
	done
	columnized[$row]="$text_row"
    done
}

if [[ $0 == *columnize.sh ]] ; then 
    #
    setopt ksharrays sh_word_split
    set -o shwordsplit
    print_columns() {
	typeset -a columnized
PS4='(%N:%i): [%?] zsh+ 
'
        columnize "$1" "$2" "$3"
	typeset -i i
	echo '==============='
	for ((i=0; i<${#columnized[@]}; i++)) ; do 
	    print "${columnized[$i]}"
	done
    }
    print_columns
    print_columns ''
    print_columns oneitem
    print_columns 'a 2 c' 10 ', '
    print_columns \
' 1   two three
  for 5   six
  7   8' 12

    print_columns \
' one two three
  4ne 5wo 6hree
  7ne 8wo 9hree
  10e 11o 12ree' 18

    print_columns \
' 1   two 3
  for 5   six
  7   8' 12

fi
