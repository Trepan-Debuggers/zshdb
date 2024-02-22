.. index:: next
.. _next:

Step Over (``next``)
--------------------

**next** [ **+** | **-** ] [ *count* ]

Step one statement ignoring steps into function calls at this level. This is sometimes called
'step over' or 'step through'.

With an integer argument, perform ``next`` that many times.

A suffix of ``+`` on the command or an alias to the command forces to
move to another line, while a suffix of ``-`` does the opposite and
disables the requiring a move to a new line. If no suffix is given,
the debugger setting 'different-line' determines this behavior.

Functions and source'd files are not traced. This is in contrast to
``step``.

.. seealso::

   :ref:`skip <skip>`, `step <step>`, and :ref:`continue <continue>` provide other ways to progress execution.
   :ref:`set different <set_different>` sets the default stepping behavior.
