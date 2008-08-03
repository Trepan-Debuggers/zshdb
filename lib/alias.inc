# Add an new alias in the alias table
typeset -A _Dbg_aliases

function add_alias {
    (( $# != 2 )) && return 1
    _Dbg_aliases[$1]=$2
    return 0
}

function remove_alias {
    (( $# != 1 )) && return 1
    unset "_Dbg_aliases[$1]"
    return 0
}

function expand_alias {
    (( $# != 1 )) && return 1
    expanded_alias=$1
    [[ -n ${_Dbg_aliases[(k)$1]} ]] && expanded_alias=$_Dbg_aliases[$1]
    return 0
}

