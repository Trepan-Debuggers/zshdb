set trace-commands on
### Test step inside multi-statement line...
p $ZSH_SUBSHELL
step 4
### Should now be inside a subshell...
p $ZSH_SUBSHELL
quit

