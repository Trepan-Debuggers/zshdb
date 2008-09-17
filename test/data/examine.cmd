set trace-commands on
# Examine with blanks
x 
x         
# Examine constant expressions
x 1+30
x '2*4+10/2'
x '(2*4+10)/2'
x "1<<4"
# Set up some values
continue 10
x ary
x string
x xstring
x fn
x z
x $ary[1]
x $ary[1]+3
quit
