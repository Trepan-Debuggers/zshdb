.. index:: quit
.. _quit:

Gentle Termination (`quit`)
---------------------------

**quit** [*exit-code* [*shell-levels*]]

The program being debugged is aborted.  If *exit-code* is given, then
that will be the exit return code. If *shell-levels* is given, then up
to that many nested shells are quit. However to be effective, the last
of those shells should have been run under the debugger.

.. seealso::

   :ref:`kill <kill>` or `kill` for more forceful termination commands. :ref:`run <run>` restarts the debugged program.
