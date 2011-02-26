set trace-commands on
### Test step inside multi-statement line...
pr $ZSH_SUBSHELL
step 4
### Should now be inside a subshell...
pr $ZSH_SUBSHELL
quit

