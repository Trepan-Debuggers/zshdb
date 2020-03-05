.. index:: kill
.. _kill:

Send Kill Signal (`kill`)
-------------------------

**kill** [ *signal-number* ]

**kill!** [*signal-number*]

Send this process a POSIX signal ('9' for 'SIGKILL' or ``kill -SIGKILL``)

9 is a non-maskable interrupt that terminates the program. If program
is threaded it may be expedient to use this command to terminate the program.

However other signals, such as 15 or ``INT`` that allow for the debugged to
handle them can be sent.

Giving a negative number is the same as using its positive value.

When the ! suffix appears, no confirmation is neeeded.

Examples:
+++++++++

::

    kill                # non-interuptable, nonmaskable kill
    kill 9              # same as above
    kill -9             # same as above
    kill 15             # nicer, maskable TERM signal
    kill! 15            # same as above, but no confirmation
    kill -INT           # same as above
    kill -SIGINT        # same as above
    kill -WINCH         # send "window change" signal
    kill -USR1          # send "user 1" signal

.. seealso::

   :ref:`quit <quit>` for less a forceful termination command, :ref:`run <run>` restarts the debugged program.
