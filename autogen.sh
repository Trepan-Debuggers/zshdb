#!/bin/zsh
autoreconf -i && \
autoconf && {
  print "Running configure with $@"
  ./configure $@
}
