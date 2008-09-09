# Sort global array, $list, starting from $1 to up to $2. 0 is 
# returned if everything went okay, and nonzero if there was an error.

# We use the recursive quicksort of Tony Hoare with inline array
# swapping to partition the array. The partition item is the middle
# array item. String comparison is used.  The sort is not stable.

sort_list() {
  (($# != 2)) && return 1
  typeset -i left=$1
  ((left < 0)) || (( 0 == ${#list[@]})) && return 2
  typeset -i right=$2
  ((right >= ${#list[@]})) && return 3
  typeset -i i=$left; typeset -i j=$right
  typeset -i mid; ((mid= (left+right) / 2))
  typeset partition_item; partition_item="${list[$mid]}"
  typeset temp
  while ((j > i)) ; do
      item=${list[i]}
      while [[ "${list[$i]}" < "$partition_item" ]] ; do
	  ((i++))
      done
      while [[ "${list[$j]}" > "$partition_item" ]] ; do
	  ((j--))
      done
      if ((i <= j)) ; then
	  temp="${list[$i]}"; list[$i]="${list[$j]}"; list[$j]="$temp"
          ((i++))
          ((j--))
      fi
  done
  ((left < j))  && sort_list $left  $j  
  ((right > i)) && sort_list $i $right
  return 0
}

if [[ $0 == *sorting.sh ]] ; then 
    [[ -n $ZSH_VERSION ]] && setopt ksharrays
    typeset -a list
    list=()
    sort_list -1 0 
    typeset -p list
    list=('one')
    typeset -p list
    sort_list 0 0 
    typeset -p list
    list=('one' 'two' 'three')
    sort_list 0 2
    typeset -p list
    list=(4 3 2 1)
    sort_list 0 3
    typeset -p list
fi
