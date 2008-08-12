# unsetopt ksharrays
typeset -a x
x=(10 20)
echo $x[1]
fooffdafsd
y='
abc'
echo another line
foo() {
  echo calling bar 10
  bar 10
}
bar() {
  x=20
}
foo arg1 $1
x=5
