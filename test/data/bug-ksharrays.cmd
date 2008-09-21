set trace-commands on
# Get past initial unsetopt
n
# Show we don't have ksharrays set
eval setopt
# Now move past set ksharrays
n
# See that we have this set inside eval
eval setopt
quit
