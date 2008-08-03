#!/bin/zsh
# -*- shell-script -*-

testAlias()
{
    add_alias q quit
    expand_alias q
    assertEquals 'quit' $expanded_alias
    remove_alias q
    expand_alias q
    assertEquals 'q' $expanded_alias
}

typeset src_dir=${src_dir:-'../../'}
. $src_dir/lib/alias.inc
. $src_dir/command/alias.cmd

# load shunit2
set -o shwordsplit

suite() {
    suite_addTest 'testAlias'
}

. ./shunit2
