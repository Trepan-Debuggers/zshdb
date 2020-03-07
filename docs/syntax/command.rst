.. _syntax_command:

Debugger Command Syntax
=======================

Command names and arguments are separated with spaces like POSIX shell
syntax. Parenthesis around the arguments and commas between them are
not used. If the first non-blank character of a line starts with `#`,
the command is ignored.

Within a single command, tokens are then white-space split. Again,
this process disregards quotes or symbols that have meaning in `zsh`.
Some commands like :ref:`eval <eval>`, have access to the untokenized
string entered and make use of that rather than the tokenized list.

Resolving a command name involves possibly 3 steps. Some steps may be
omitted depending on early success or some debugger settings:

1. The leading token is next looked up in the debugger alias table and
the name may be substituted there. See "help alias" for how to define
aliases, and "show alias" for the current list of aliases.

2. After the above, The leading token is looked up a table of debugger
commands. If an exact match is found, the command name and arguments
are dispatched to that command.

3. If after all of the above, we still don't find a command, the line
may be evaluated as a zsh statement in the current context of the
program at the point it is stoppped. However this is done only if
"auto evaluation" is on.  It is on by default.

If :ref:`auto eval <set_autoeval>` is not set on, or if running the
Python statement produces an error, we display an error message that
the entered string is "undefined".

If you want zsh shell command-processing, it's possible to go into an
python shell with the corresponding the command `zsh` or `shell`. It
is also possible to arrange going into an python shell every time you
enter the debugger.

See also:
---------

:ref:`help syntax suffixes <syntax_suffixes>`
