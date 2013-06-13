#!/bin/zsh
autoreconf -i && \
autoconf && {
  echo "Running configure with --enable-maintainer-mode $@"
  cp README.md README
  ./configure --enable-maintainer-mode $@
}
