# unsetopt ksharrays
typeset -a x
x=(10 20)
echo ${x[1]}
fooffdafsd
y='
abc def'
x=($y)  # get different results if unsetopt shwordsplit
( echo another line )
foo() {
  echo calling bar 10
  bar 10
}
bar() {
  x=20
}
foo arg1 $y
x=5
