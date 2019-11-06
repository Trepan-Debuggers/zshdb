# !/usr/bin/zsh -f
# Returns 0 if run with a zsh compatible with zshdb
PS4='%(%x:%I): [%?]
'

second_fn() {
  zmodload zsh/parameter
  if ! (( ${+funcfiletrace} )) ; then
    print "Looks like you don't have funcfiletrace."
    print "We need a zsh new enough which has that."
    exit 10
  fi
  fn=$funcfiletrace[-2]
  if [[ $fn != *ok4zshdb.sh:22 ]]; then
    print "Didn't get the answer back from funcfiletrace[1] I was expecting"
    print "Got: $fn"
    exit 15
  fi
}

functrace_no_source() {
  second_fn
}

typeset -fuz is-at-least  # Same as "functions -u -z" but better documented.
if ! is-at-least 5.4.1 ; then
    print "zsh needs version 5.4.1 or greater"
    exit 20
else
    print $(zsh --version) is recent enough.
fi

functrace_no_source

debug_hook() { . ./ok4zshdb2.sh; }

function get_processor {
    setopt ksharrays
    typeset -a cmd
    cmd=( $(COLUMNS=3000 ps h -o comm -p $$) ) 2>/dev/null
    if (( $? == 0 )); then
        ZSH_PROCESSOR=${cmd[0]}
    else
        # Solaris doesn't have "h" on ps
	cmd=( $(COLUMNS=3000 ps -o args -p $$ | tail -1) ) 2>/dev/null
        ZSH_PROCESSOR=${cmd[0]}
    fi
}

get_processor
$ZSH_PROCESSOR -if ./ok4zshdb3.sh
if (( $? != 1 )) ; then
    print "Your zsh doesn't have the fc -l patches."
fi

. ./trap-bug1.sh && {
  print "Your zsh doesn't handle \$? inside traps properly"
  exit 30
}

# trap-bug1.sh is supposed to exit 0. So if
# you get here no dice.
print "Internal test error you. You shouldn't be seing this."
exit 40
