#!/usr/local/bin/zsh -f
# Returns 0 if run with a zsh compatible with zshdb

second_fn() {
  decls=$(declare -p)
  if [[ $decls != *funcfiletrace* ]] ; then
    print "Looks like you don't have funcfiletrace."
    print "We need a zsh new enough which has that."
    exit 10
  fi
  fn=$funcfiletrace[1]
  if [[ $fn != *ok4zshdb.sh:20 ]]; then
    print "Didn't get the answer back from funcfiletrace[1] I was expecting"
    print "Got: $fn"
    exit 15
  fi
}

functrace_no_source() {
  second_fn
}

typeset -fuz is-at-least  # Same as "functions -u -z" but better documented.
if ! is-at-least 4.3.6-dev-0 ; then
  print "zsh needs version 4.3.6-dev-0 or greater"
  exit 20
fi

functrace_no_source

. ./trap-bug1.sh && {
  print "Your zsh doesn't handle \$? inside traps properly"
  exit 30
}

debug_hook() { . ./is-dbg-ok3; }

trap 'debug_hook' DEBUG
. ./is-dbg-ok2
# If you get here is-dbg-ok2 didn't work. Failure
print "Your zsh doesn't handle trap DEBUG properly."
exit 40

