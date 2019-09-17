.. contents:: :local:

Features
========

Since this debugger is similar to other_ trepanning_ debuggers_ and *gdb*
in general, knowledge gained by learning this is transferable to those
debuggers and vice versa.

Source-code Syntax Colorization
-------------------------------

Terminal source code is colorized via pygments_ . And with that you
can set the pygments color style, e.g. "colorful", "paraiso-dark". See
set_style_ . Furthermore, we make use of terminal bold and emphasized
text in debugger output and help text. Of course, you can also turn
this off.


Command Completion
------------------

Terminal command completion is available. Command completion is not
just a simple static list, but varies depending on the context. For
example, for frame-changing commands which take optional numbers, on
the list of *valid numbers* is considered.

Terminal Handling
-----------------

We can adjust debugger output depending on the line width of your
terminal. If it changes, or you want to adjust it, see set_width_ .

Smart Eval
----------

If you want to evaluate the current source line before it is run in
the code, use ``eval``. To evaluate text of a common fragment of line,
such as the expression part of an *if* statement, you can do that with
``eval?``. See eval_ for more information.

More Stepping Control
---------------------

Sometimes you want small steps, and sometimes large stepping.

This fundamental issue is handled in a couple ways:

Step Granularity
................

There are now ``step`` *event* and ``next`` *event* commands with
aliases to ``s+``, ``s>`` and so on. The plus-suffixed commands force
a different line on a subsequent stop, the dash-suffixed commands
don't.  Without a suffix you get the default; this is set by the :ref:`set different <set_different>` command.


.. _pygments:  http://pygments.org
.. _pygments_style:  http://pygments.org/docs/styles/
.. _other: https://www.npmjs.com/package/trepanjs
.. _trepanning: https://pypi.python.org/pypi/trepan2
.. _debuggers: https://metacpan.org/pod/Devel::Trepan
.. _this: http://bashdb.sourceforge.net/pydb/features.html
.. _set_substitute:  https://zshdb.readthedocs.org/en/latest/commands/set/substitute.html
.. _set_style:  https://zshdb.readthedocs.org/en/latest/commands/set/style.html
.. _set_width:  https://zshdb.readthedocs.org/en/latest/commands/set/width.html
.. _eval: https://zshdb.readthedocs.org/en/latest/commands/data/eval.html
.. _step: https://zshdb.readthedocs.org/en/latest/commands/running/step.html
.. _install: http://zshdb.readthedocs.org/en/latest/install.html
