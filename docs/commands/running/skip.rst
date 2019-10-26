.. index:: skip
.. _skip:

Skip (skip over)
----------------

**skip**

Skip (don't run) the next command(s).

Note that skipping doesn't change the value of \$?. This has
consequences in some compound statements that test on \$?. For example
in:

   if grep foo bar.txt ; then
      echo not skipped
   fi

skipping the *if* statement will in effect skip running the *grep*
command. Since the return code is 0 when skipped, the *if* body is
entered. Similarly the same thing can  happen in a *while* statement
test.

.. seealso::

   :ref:`next <next>` command. :ref:`step <step>`, :ref:`continue <continue>`, and :ref:`finish <finish>` provide other ways to progress execution.
