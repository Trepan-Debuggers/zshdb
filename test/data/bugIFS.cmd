set trace-co on
# Debugger test of an old IFS bug
#
step
## Make sure PS4 in an eval is the same as what we just set.
pr "+$IFS+"
quit
kill!
