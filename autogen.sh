#!/bin/zsh
autoreconf -i && \
autoconf && {
  echo "Running configure with --enable-maintainer-mode $@"
  ./configure --enable-maintainer-mode $@
}
