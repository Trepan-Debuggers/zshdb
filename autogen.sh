#!/bin/zsh
cp README.md README
autoreconf -i && \
autoconf && {
  echo "Running configure with --enable-maintainer-mode $@"
  ./configure --enable-maintainer-mode $@
}
