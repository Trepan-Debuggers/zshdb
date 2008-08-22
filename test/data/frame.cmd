set trace-commands on
# Test of frame commands
# We also try all of the various where/backtrace variants
# Do we give a valid stack listing initially?
where
# How about after a frame command? 
frame 0
bt
where
# How about after moving?
u
where
down
where
# Try moving past the end
down
where
up 2
bt
# Try some negative numbers
# should be the same as up
down -1
T
# Should to to least recent frame
frame -1
where
# Let's add another stack entry
continue hanoi
where
# Again least recent stack entry
frame -1
where
# Most recent stack entry
frame +0
backtrace
up 2
quit



