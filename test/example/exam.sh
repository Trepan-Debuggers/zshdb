#!/bin/zsh
# For testing examine.
unsetopt ksharrays
ary=(10 100 100)
string='a string'
export xstring='an exported string'
readonly ary
fn() { print "a function"; }
z=1
unset string
r='abc'

