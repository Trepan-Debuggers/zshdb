.. index:: debug
.. _debug:

Recursive Debugging (`debug`)
-----------------------------

**debug** [*zsh-script* [*args*...]]

Recursively debug into *zsh-script*.

If *script* is not given, take the script name from the command that
is about to be executed. Note that when the nested debug finished, you
are still where you were prior to entering the debugger.

.. seealso::

   :ref:`skip <skip>`, and :ref:`run <run>`
