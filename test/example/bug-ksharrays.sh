#!/bin/zsh -f
# Had bug in not setting ksharray inside eval of debugger
unsetopt ksharrays
setopt ksharrays sh_word_split
x=1
