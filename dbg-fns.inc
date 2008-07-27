# -*- shell-script -*-

# Split string $1 into an array using delimitor $2 to split on
# The result is put in variable split_result
function _Dbg_split {
    local string="$1"
    local separator="$2"
    IFS="$separator" read -A split_result <<< $string
}

function _Dbg_msg {
    print "$@" 
}
