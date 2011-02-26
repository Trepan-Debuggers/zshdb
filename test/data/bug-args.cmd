set trace-commands on
# Debugger test to see that parameter handling of $1, $2, etc is correct.
pr $#
pr $5
step 2
# There should now be 5 args set and $5 should have a value
pr $#
pr $3
pr $5
step
# There should now be 3 args set and $5 should not have a value
pr $#
pr $3
pr $5
quit

