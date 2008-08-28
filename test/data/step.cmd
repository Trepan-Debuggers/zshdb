set trace-commands on
# Make sure autostep is off for next text
set force off
show force
# Test that step+ skips multiple statements
step+
set force on 
show force
# Same thing - skip loop
step 
# Override force
step-
s-
# A null command should use the last step

step 
# Try a null command the other way
s+

quit



