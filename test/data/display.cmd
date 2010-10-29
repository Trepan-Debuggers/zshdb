set trace-commands on
# Test break, watch, watche, step, next, continue and stack handling
#
###  Try a simple display...
display $x
break 23
break 25
cont
###  Try disabling display ...
disable display 0
info display
step
step
###  Try enabling display ...
enable display 0
info display
###  Try display to show again status ...
display
info display
###  Try undisplay to delete ...
undisplay
undisplay 0
info display
step
step
###  quitting...
quit
