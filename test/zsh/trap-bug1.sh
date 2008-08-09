#!/bin/zsh -f
# Tests for $? not set properly inside trap DEBUG.
set_dollar_question() { return 1; }
set -o DEBUG_BEFORE_CMD
trap '[[ $? -ne 0 ]] && exit 0' DEBUG
set_dollar_question
# If you didn't exit above, then failure
exit 10
