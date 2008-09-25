set trace-commands on
# Test of debugger 'list' command
#
help l
### List default location
list 
### Should list next sets of lines
l
l
l
### Original set and then beginning
l . 
list -
#
# Should not see anything since we are out of bounds
# 
list 999
#########################################################
### 'list file:line' and canonicalization of filenames...
list ../example/dbg-test1.sh:1
list ../example/dbg-test1.sh:20
list ../example/dbg-test1.sh:30
list ../example/dbg-test1.sh:999
list ./badfile:1
#########################################################
set trace-commands on
### list of functions...
## list fn1
## list bogus
#########################################################
### Testing window command..."
## window 
###  Testing '.'
# l . 
# 
###  Testing set/show listsize
show listsize
###  Setting listsize to 3...
set listsize 3
l 10
###  Window command...
## w
## p "- command..."
## -
###  Setting listsize to 4...
set listsize 4
show listsize
l 10
###  Window command...
## w
###  '-' command...
### -
#<-This comment doesn't have a space after 
#the initial `#'
quit
