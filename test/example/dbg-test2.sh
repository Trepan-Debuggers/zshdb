#!../../bash
# -*- shell-script -*-
# Note: no CVS Id line since it would mess up regression testing.
# This code is used for various debugger testing.

fn1() {
    echo "fn1 here"
    x=5
    fn3
}    

fn2() {
    name="fn2"
    echo "$name here"
    x=6
}    

fn3() {
    name="fn3"
    x=$1
}    

# Test that set -xv doesn't trace into the debugger.
set -xv
x=24
x=25
for i in 0 1 3 ; do
  ((x += i))
done
set +xv
x=27
y=b
x=29
echo $(fn3 30)
fn3 31
fn1;
fn3 33
exit 0
