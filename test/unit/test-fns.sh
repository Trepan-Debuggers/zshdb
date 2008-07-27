#!/bin/zsh
# -*- shell-script -*-

testSplit()
{
    _Dbg_split 'foo.c:5' ':'
    assertEquals 'foo.c' ${split_result[1]}
    assertEquals '5' ${split_result[2]}
}

typeset src_dir=${src_dir:-'../../'}
. $src_dir/dbg-fns.inc

# load shunit2
set -o shwordsplit

suite() {
    suite_addTest 'testSplit'
}

. ./shunit2

