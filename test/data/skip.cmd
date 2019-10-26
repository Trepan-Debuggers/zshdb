set trace-commands on
# Make sure autostep is off for tests
set force on
# Test that skip skips multiple statements
n
x x
skip fdafsdg
skip
x x
n
skip 2
x x
n
skip 1+2
c
quit
