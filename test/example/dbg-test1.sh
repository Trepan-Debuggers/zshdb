#!/bin/zsh -f
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

x=22
y=23
for i in 0 1 3 ; do
  ((x += i))
done
x=27
y=b
x=29
echo $(fn3 30)
fn3 31
fn1;
fn3 33
source ./dbg-test1.sub
exit 0
