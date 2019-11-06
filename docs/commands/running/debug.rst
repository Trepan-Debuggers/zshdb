.. index:: run
.. _run:

Run (restart program execution)
-------------------------------
**debug** [*zsh-script* [*args*...]]

Set up *zsh-script* for debugging.

If *script* is not given, take the script name from the command that
is about to be executed. Note that when the nested debug finished, you
are still where you were prior to entering the debugger.

.. seealso::

   :ref:`skip <skip>`, and :ref:`run <run>`
