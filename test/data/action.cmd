set trace-commands on
set basename on
# Debugger test of action command
#
# Try a simple action action...
a
a 23 x=60
L
a
cont 24
eval echo "value of x is now $x"
quit
