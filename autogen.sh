#!/bin/zsh
set -x
autoreconf -i && \
autoconf && \
./configure 
