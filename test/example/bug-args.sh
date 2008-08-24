#!/bin/zsh
echo First parm is: $1
set a b c d e
shift 2
# At this point we shouldn't have a $5 or a $4
exit 0
