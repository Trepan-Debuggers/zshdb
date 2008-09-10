set trace-commands on
# Make sure autostep is off for next text
set force on
###############################
# Invalid delete commands
delete 0
break 4
delete 4
info break
###############################
# Should work
delete 1
info break
###############################
# Should fail - already deleted
delete 1
break 5
continue
# Should stop at line 5 not 4
where 1
info break
break 6
###############################
# try deleting multiple breakpoints
delete 2 3
info break
###############################
# Should be able to set several brkpts on same line.
break 7
break 7
continue
# Should be at breakpoint but not one that's been deleted
where 1
quit




