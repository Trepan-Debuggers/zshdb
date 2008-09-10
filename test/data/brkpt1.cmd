set trace-commands on
# 
# Test of breakpoint handling
#
# Test the simplest of breakpoints
break 22
info break
###############################################################
####  Test enable/disable...
## enable 1
## disable 1
################################################################
####  Try setting breakpoints outside of the file range...
## break 99
break 0
# 
# list breakpoints
L
#### Try Deleting a non-existent breakpoint...
## clear 10
## d 0
###############################################################
#### Test display status...
## delete 1
## info break
break 22
info break
###############################################################
#### *** Test using file:line format on break...
break ../example/dbg-test1.sh:23
break ../example/dbg-test1.sh:0
## break ../example/dbg-test1.sh:1955
break 23
info break
# delete 3
###############################################################
#### Test breakpoints with conditions...
# break 23 if x==0
# break 24 y > 25
# info break
# condition 23
# condition
# info break
# condition x==1
# condition 4 x==1
# condition bad
# condition 30 y==1
# disable 2 5
# info break
# enable 2 6
# delete 2 6
#### Test info break...
# info break 11
# info break foo
# info break 5
# d 23
# L
quit
