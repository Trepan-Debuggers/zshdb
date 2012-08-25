set trace-commands on
# Test of frame commands
# We also try all of the various where/backtrace variants
# Do we give a valid stack listing initially?
where 1
# How about after a frame command? 
frame 0
bt 1
where 1
# Let's start with a couple of stack entries
step 7
where 2
# How about after moving?
up
where 1
# Try moving past the end
down 2
where 5-3
up 3
# Try some negative numbers
# should be the same as up
down -1
T 2
# Should go to next-to-least-recent frame
frame -2
where 2
# Let's add another stack entry
## continue hanoi
step 12
where 3
# Again, next-to-least recent stack entry
frame -2
where 3
# Most recent stack entry
frame +0
backtrace 3
up 2
quit



