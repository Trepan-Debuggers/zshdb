.. index:: skip
.. _skip:

Skip over statement (`skip`)
----------------------------

**skip** [ *count* ]

Skip over (don't run) the next *count* command(s).

If *count* is given, stepping occurs that many times before
stopping. Otherwise *count* is one. *count* can be an arithmetic
expression.

Note that skipping doesn't change the value of \$?. This has
consequences in some compound statements that test on \$?. For example
in:

::

   if grep foo bar.txt ; then
      echo not skipped
   fi

Skipping the *if* statement will, in effect, skip running the *grep*
command. Since the return code is 0 when skipped, the *if* body is
entered. Similarly the same thing can  happen in a *while* statement
test.

.. seealso::

   :ref:`next <next>`,  :ref:`step <step>`, and :ref:`continue <continue>` provide other ways to progress execution.
