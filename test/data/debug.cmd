set trace-commands on
#### Test 'debug' command
continue 8
where 1
print running debug -n ./debug.sh $_Dbg_DEBUGGER_LEVEL ...
debug -B -q --no-highlight --no-init -x ../data/debug2.cmd ../example/debug.sh $_Dbg_DEBUGGER_LEVEL
quit
