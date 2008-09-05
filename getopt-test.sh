# Test for a getopt that handles long options properly.
TEMP=$(getopt -o :h --long help,library: -n 'foo' -- "--help")
if [[ " --help --" == $TEMP ]] ; then
    exit 0
else
    exit 1
fi
