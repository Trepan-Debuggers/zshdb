set trace-commands on
# Test of debugging through a subshell
x x
step
examine x
s 
print $ZSH_SUBSHELL
examine x
s
# Set inside a subshell
set autoeval on
examine x
# fc -l
s 
x x
print $ZSH_SUBSHELL
# See that debugger settings and history are preserved
# DISABLED because we are not in an interactive tty
show autoeval
# fc -l
s 3
x x
print $ZSH_SUBSHELL
# A quit inside a nested subshell.
quit

