# Testing subshell and backtick
x=2
( x='line 3';
  y='line 4' 
) # > /dev/null 2>&1
( 
    x=$(print line 7)
    y='line 8'
)
x=10
