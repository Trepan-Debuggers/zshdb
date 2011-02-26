set trace-commands on
set showcommand on
# Test step inside multi-statement line...
cont 14
step
pr $ZSH_SUBSHELL
quit 0 56
quit
