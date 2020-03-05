.. index:: down
.. _down:

Relative Frame Motion towards more-recent Frame (`down`)
--------------------------------------------------------

**down** [ *count* ]

Move the current frame down in the stack trace (to a newer frame). 0
is the most recent frame. If no count is given, move down 1.

When you enter the debugger this command doesn't make a lot of sense
because you are at the most-recently frame. However if you issue
`down` and `frame` commands, this can change.


.. seealso::

   :ref:`up <up>` and :ref:`frame <frame>`.
