set trace-commands on
# Debugger test to see that parameter handling of $1, $2, etc is correct.
eval echo "basename(dollar 0) = $(basename $0)"
pr $#
pr $5
step 4
# There should now be 5 args set and $5 should have a value
pr $#
pr $3
pr $5
step
# There should now be 3 args set and $5 should not have a value
pr $#
pr $3
pr $5
c 9
# $0 should be changed
eval echo "Dollar 0 from eval is now $0"
quit
