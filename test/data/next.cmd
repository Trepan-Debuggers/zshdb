set trace-commands on
set basename on
# Make sure autostep is off for next text
set force off
show force
next
where 1
n
where 1
# Test that next+ skips multiple statements
next+
where 1
# Same thing - but should stop at 2nd statement in line
next 
where 1
next
where 1
# Now check with set force on
set force on
show force
next
where 1
# Override force
next-
where 1
n-
where 1
# A null command should use the last next

where 1

next 
where 1
# Try a null command the other way
n+
where 1

where 1
quit



