PS4='(%x:%I): [%?] zsh+
'
setopt ksharrays
set -o shwordsplit
shunit_file=${abs_top_srcdir}test/unit/shunit2
_Dbg_libdir=$abs_top_srcdir
shunit_file=${abs_top_srcdir}test/unit/shunit2

# Don't need to show banner
set -- '-q'
