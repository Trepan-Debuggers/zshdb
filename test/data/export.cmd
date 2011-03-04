# Make sure export command saves values
set trace-commands on
set showcommand 1
export
step
export foo
export x
c 3
set autoeval on
step 
x=30
export x
c 10
x x
quit
