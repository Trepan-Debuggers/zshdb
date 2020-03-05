.. index:: alias
.. _alias:

Add Debugger Command Alias (`alias`)
------------------------------------

**alias** *alias-name* *debugger-command*

Add alias *alias-name* for a debugger command *debugger-comand*.

Add an alias when you want to use a command abbreviation for a command
that would otherwise be ambigous. For example, by default we make ``s``
be an alias of ``step`` to force it to be used. Without the alias, ``s``
might be ``step``, ``show``, or ``set`` among others

Examples:
+++++++++

::

        alias cat list   # "cat myprog.sh" is the same as "list myprog.sh"
        alias s   step   # "s" is now an alias for "step".
                         # The above example is done by default.

.. seealso::

   :ref:`unalias <unalias>` and :ref:`show alias <show_aliases>`.
