set trace-commands on
set showcommand 1
#### Test step inside multi-statement line...
step 
step
step 2
#### Should now be inside a subshell. Test from here...
pr $ZSH_SUBSHELL
quit 0 2
quit

