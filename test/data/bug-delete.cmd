set trace-commands on
# Test bug we had where clearing a break on one line
# was disabling a break on the next one
#

break 3
break 5
break 7
delete 2
continue
continue
# Should have stopped at line 7 above
quit
