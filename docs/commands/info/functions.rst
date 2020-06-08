.. index:: info; functions
.. _info_functions:

Info Functions
--------------

**info functions** [*string-pattern*]

List function names. If *string-pattern* is given, the results
are filtered using the shell ``=`` (or ``==``) test.
list global and static variable names.

Examples:
+++++++++

::

    info functions    # show all functions
    info functions co # show all functions with "co" in the name

.. seealso::

   :ref:`info line <info_line>`, and :ref:`info program <info_program>`.
