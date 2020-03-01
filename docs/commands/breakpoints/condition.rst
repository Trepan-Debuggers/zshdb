.. index:: condition
.. _condition:

Add Condition to a Breakpoint (condition)
-----------------------------------------

**condition** *bp_number* *condition*

*bp_number* is a breakpoint number. *condition* is a zsh expression
which must evaluate to *True* before the breakpoint is honored.  If
*condition* is absent, any existing condition is removed; i.e., the
breakpoint is made unconditional.

Examples:
+++++++++

::

   condition 5 x > 10  # Breakpoint 5 now has condition x > 10
   condition 5         # Remove above condition

.. seealso::

   :ref:`break <break>`, :ref:`tbreak <tbreak>`.
