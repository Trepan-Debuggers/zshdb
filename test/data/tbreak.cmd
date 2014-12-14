# Test of temporary breakpoints including those via "continue"
set trace-commands on
# Get past line 3
step
# Temporary breakpoint inside function
tbreak 3
info breakpoints
# Should stop at line 3
continue 6
# Breakpoint at line 6 should still be shown
info breakpoints
continue
# Now we get to line 6 and
# no more breakpoints should be shown.
info breakpoints
quit
