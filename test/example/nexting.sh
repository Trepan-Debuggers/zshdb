#!/bin/zsh
# For testing next, next+ next-, default next and set force.
p() { print ${funcfiletrace[0]##*/}; print '==='; }
setopt ksharrays
p 
p ; x=6
p ; x=7
p ; x=8
p ; x=9
p ; x=10
p ; x=11
p ; x=12
p ; x=13
x=14
