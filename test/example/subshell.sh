#!/bin/zsh
# Test debugger handling of subshells
(
    builtin cd  . 
    x=$(builtin echo 5)
    ( builtin print 'another subshell' )
)
( x=6
  print 'second subshell'
) >/dev/null 2>&1

