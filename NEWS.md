Version 1.1.2 2019-12-10 gecko gecko
------------------------------------

Very minor improvements

- Add "show prompt" to "show" list
- add "show dir"  to "show" list
- Show *all* Pygments sytles a has installed, not just builtins. (John Purnell in bashdb)
- Fix typo which prevented syntax highlighting option from working (MenkeTechnologies)

Version 1.1.1 2019-11-17 JNC
----------------------------

- clean up and document better set/show commands
	- autoeval,
	- autolist
	- confirm,
    - different
	- linetrace
	- trace-command
	- listsize,
	- width
- more RsT formatting in set/show commands
- Silence "stty echo" failures in terminal detection
- Add set/show confirm
- Add ! suffix to kill command
- set $0 properly inside "eval" and "shell commands
- bump min zshdb version at least 5.4.1 to avoid memory corruption when setting $0
- other small fixes and doc improvements


Version 1.1.1 2019-10-27 9 x 7
-------------------------------

- Add "skip" command
- Add "debug" command
- Lots of little help doc fixes
- Update for current pygments advances. Now use the default TERMINAL colors

Version 1.0.1 2019-09-18
-------------------------

- Revise "info variables"
- Update help for "info variables"
- Test for pygments on install
- Detect light/dark terminal using program from bash-terminal project (adjusted for zsh)


Version 1.0.0 2018-10-27
------------------------

- Untabify some sources
- Better handling of paths with embedded blanks
- Add --tty_in and --terminal_in
- backtrace with more eatures
     * Allow negative count.
     * Option -s or --source show source-code line in backtrace
- Document how tests work
- More sub-indexing in command help
- Other documentation improvements
- "set style" lists all available pygments styles
- allow gdb-style enable/disable/delete all brkpts
- _Dbg_write_journal_avar for zsh 5.1 and 5.4
- unvarnished "typeset -p" output Fixes issue #12 Fixes #10
- Sync with bashdb. Closer gdb conformance
- Fix test for funcfiletrace on later zshdb in ok4zshdb

Version 0.92 2016-07-06
------------------------

- Allow source-code colorization via pygments style.
  use "set style"
- Help text now formated via Rst.
- Paragraph reflow adjusts to line width
- Revise help docs

Version 0.91
2016-05-30 Mom

- Report deleted breakpoints This helps front-ends like realgud
- Fix some of the highlight bugs
- add parameter to option --highlight=dark|light. We now accomdate dark terminals more properly.
- 2st level completion of "set" and "show" and "info" commands
- frame order on completion respected
- add underline attribute and use it for errors and debugger prompt
- add sectioning to on-line help
- add set history filename
- add help completion,
- help include aliases
- numerous bug fixes

Version 0.9 2014-12-12 Late Gecko
---------------------------------

Note there are some incompatible changes in behavior. Some changes or
follow gdb more closely, others make the default settings useful.

- 'u' is no longer up and 'd' is 'delete' not 'down'
- set highlight on by default now.
- Set editing is on by default too.
- 1st level completion of "set" and "show" command
- fix bug in delete
- improve help
- misc bug and doc fixes

Version 0.08 2011-4-18
----------------------

- add some limited tab completion
- Remove hard-wiring of "info", "set", and "show" commands.
- expand help text for various commands
- "set debugging" is not "set debug" to match gdb
- unit tests are faster and have less white space but more useful information
- eval? evaluates the RHS of an assignment statement
- bug fixes

Version 0.07 - Ides of March 2011-3-15
--------------------------------------

- syntax coloring if the Python pygments package installed (and
  --highlight option used)
- easy way to evaluate the current source line or expression inside
  the source line (debugger commands "eval" and "eval?")
- ability to go into a nested shell but keeping existing variables and
  functions set. (debugger command "shell") With this, one needs...
- ability to save variables to an outer shell ("set_vars" function
  inside the interactive shell)
- ability to save values from inside a subshell to the outer shell
  (debugger command "export")
- add debugger "display" and "undisplay" commands
- add --init-file (akin to same option in bash) to have zsh code
  sourced

Version 0.06 "Giant Madagascar Day" 2010-12-10
----------------------------------------------

- Debugger "list" command carries on where we last left off. By default
  it centers around the selected line. Use list> to force starting at the line.
- Reorganized command-processing code to simplify it, make it more dynamic,
  and allow for better expansion increasing DRYness. As a result
  some short abbreviations of commands have been dropped. Use "alias"
  to add back any that you want.

Version 0.05 2010-10-27
-----------------------

- Add debugger "action" command
- Add debugger set/show autolist
- Fix bugs when file contained spaces in a directory portion of the path
- "Set force" depricated. Use "set different".
- Code reorganization to support subcommands (set/show/info) and allow
  for growth
- Emacs lisp code has been removed. Please multi-debugger code from
  http://github.com/rocky/emacs-dbgr instead.
- Other bug fixes

Version 0.04 2009-10-27 Halala ngosuku lokuzalwa
------------------------------------------------

- Better tolerance for files with embedded blanks. Make sure to quote
  parameters in argument passing.

- Add "set force", "step+", and "step-", "next+", and "next-" commands.

- Preface more variable names with _Dbg_.

- Remove Emacs compile warnings

Version 0.03 2009-07-04
------------------------

- add debugger "kill" command
- add debugger "condition" command
- add set-inferior tty and tty testing code changes
- add manual page; help doc improvements
- more and better unit/integration tests
- works on Solaris

Version 0.02 2008-11-17
-----------------------

- Fix bugs: in breakpoints, "info args", "show version" and --version

Version 0.01 2008-10-27
-----------------------

First public release
