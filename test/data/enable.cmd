set trace-commands on
###############################
break 5
break 3 
info break
disable 1
# Already disabled.
disable 1
# Invalid disable
disable 10
continue
info break
enable 1
# enable an already enabled breakpoint
enable 2
disable 2
break 6
enable 10
continue
# Should get back to 6
info break
info program
c
info break
quit
