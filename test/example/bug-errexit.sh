#!/bin/zsh -f
# Had bug in not handling when errexit was set. 
# We'll also test set -u.
set -o errexit
set -u
print one
