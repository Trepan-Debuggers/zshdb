.. _zshdb:

.. toctree::
.. contents::

zshdb command
#############

Synopsis
--------


**zshdb** [ *debugger-options* ] [ \-- ] [ *zsh-script* [ *script-options* ...]]

**zshdb** [ *options*] -c *execution-string*

Description
-----------

*zshdb* is a *zsh* script to which arranges for another *zsh* script
to be debugged.

The debugger has a similar command interface as gdb_.

If your zsh script needs to be passed options, add ``--`` before the
script name. That will tell *zshdb* not to try to process any further
options.

Options
--------

:-h | --help:

Print a usage message on standard error and exit with a return code
of 100.

:-A | --annotation *level*:

Sets to output additional stack and status information which allows
front-ends such as Emacs to track what's going on without polling.

This is needed in for regression testing. Using this
option is equivalent to issuing:

::

    set annotate LEVEL

inside the debugger. See :ref:`set annotate <set_annotate>` for more information on that command

:-B | --basename:

In places where a filename appears in debugger output give just the
basename only. This is needed in for regression testing. Using this
option is equivalent to issuing:

::

   set basename on

inside the debugger. See :ref:`set basename <set_basename>` for more information on that command


:-n | --nx | --no-init:

Normally the debugger will read debugger commands in `~/.zshdbinit` if
that file exists before accepting user interaction.  `.zshdbinit` is
analogous to GNU gdb's `.gdbinit`: a user might want to create such a
debugger profile to add various user-specific customizations.

Using the `-n` option this initialization file will not be read. This
is useful in regression testing or in tracking down a problem with
one's `.zshdbinit` profile.


:-c | --command *command-string*:

Instead of specifying the name of a script file, one can give an
execution string that is to be debugged. Use this option to do that.


:-q | --quiet:

Do not print introductory version and copyright information. This is
again useful in regression testing where we don't want to include a
changeable copyright date in the regression-test matching.


:-x | --eval-command *debugger-cmdfile*:

Run the debugger commands *debugger-cmdfile* before accepting user
input.  These commands are read however after any `.zshdbinit`
commands. Again this is useful running regression-testing debug
scripts.


:-L | --library *debugger-library*:

The debugger needs to source or include a number of functions and
these reside in a library. If this option is not given the default
location of library is relative to the installed zshdb script:
`../lib/zshdb`.



:-T | --tempdir *temporary-file-directory*:

The debugger needs to make use of some temporary filesystem storage to
save persistent information across a subshell return or in order to
evaluate an expression. The default directory is `/tmp` but you can
use this option to set the directory where debugger temporary files
will be created.


:-t | --tty *tty-name*:

Debugger output usually goes to a terminal rather than stdout or stdin
which the debugged program may use. Determination of the tty or
pseudo-tty is normally done automatically. However if you want to
control where the debugger output goes, use this option.


:-V | --version:

Show version number and no-warranty and exit with return code 1.

Bugs
----

The way this script arranges debugging to occur is by including (or
actually "source"-ing) some debug-support code and then sourcing the
given script or command string.

One problem with sourcing a debugged script is that the program name
stored in ``$0`` will not be the name of the script to be debugged. The
debugged script will appear in a call stack not as the top item but as
the item below `zshdb`.

The `zshdb` script option assumes a version of zsh with debugging
support, zsh 4.3.6-dev-2 or later.

The debugger slows things down a little because the debugger has to
intercept every statement and check to see if some action is to be taken.

See also
---------

* `bashdb manual <http://bashdb.sourceforge.net/bashdb.html>`_ - Until a full manual is written, this manual for a similar bash debugger may give some guidance. The two debuggers have similar command interfaces (and code).
* `zshdb github <https://github.com/rocky/zshdb>`_ - the github project page

Author
------

The current version is maintained (or not) by Rocky Bernstein.

Copyright
---------

Copyright (C) 2009, 2017, 2019 Rocky Bernstein
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

.. _gdb: http://sourceware.org/gdb/current/onlinedocs/gdb_toc.html
