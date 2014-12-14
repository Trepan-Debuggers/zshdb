set trace-commands on
#
# Test of condition handling (on breakpoints)
###############################################################
break 23 if x==0
break 24 y > 25
info breakpoints
condition 23
condition
info breakpoints
condition x==1
condition 4 x==1
condition bad
condition 30 y==1
info breakpoints
quit
