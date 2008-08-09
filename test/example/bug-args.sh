#!/bin/zsh
# $Id: bug-args.sh.in,v 1.2 2006/12/19 00:39:28 rockyb Exp $
echo First parm is: $1
set a b c d e
shift 2
# At this point we shouldn't have a $5 or a $4
exit 0
