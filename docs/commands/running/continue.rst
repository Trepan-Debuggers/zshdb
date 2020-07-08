.. index:: continue
.. _continue:

Continue Program Execution (`continue`)
---------------------------------------

**continue** [ *loc* | **-*** ]

If *loc* or *-* is not given, continue until the next breakpoint or
the end of program is reached.  If **-** is given, then debugging will
be turned off after continuing causing your program to run at full
speed.

If **loc** is given, a temporary breakpoint is set at the location.

Examples:
+++++++++

::

    continue          # Continue execution
    continue 5        # Continue with a one-time breakpoint at line 5

.. seealso::

   :ref:`next <next>` :ref:`skip <skip>`, and :ref:`step <step>` provide other ways to progress execution.
