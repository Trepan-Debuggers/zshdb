#!/bin/zsh -f
# Returns 0 if run with a zsh compatible with zshdb

functrace_no_source() {
  second_fn
}
second_fn() {
  fn=$functrace[1]
  if [[ $fn == 'functrace_no_source:1' ]]; then
    print "Your functrace does not report file names and line numbers properly."
    exit 10
  fi
}

functrace_no_source

. ./trap-bug1.sh && {
  print "Your zsh doesn't handle \$? inside traps properly"
  exit 20
}

debug_hook() { . ./is-dbg-ok3; }

trap 'debug_hook' DEBUG
. ./is-dbg-ok2
# If you get here is-dbg-ok2 didn't work. Failure
print "Your zsh doesn't handle trap DEBUG properly."
exit 30

