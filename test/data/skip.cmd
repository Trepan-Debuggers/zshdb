set trace-commands on
# Make sure autostep is off for next text
set force on
# Test that skip skips multiple statements
skip
where 1
skip 2
where 1
quit



