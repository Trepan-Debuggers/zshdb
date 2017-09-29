.. index:: backtrace
.. _backtrace:

Backtrace (show call-stack)
---------------------------

**backtrace** [*count*]

Print a stack trace, with the most recent frame at the top.  With a
positive number, print at most many entries.  With a negative number
print the top entries minus that number.

An arrow indicates the 'current frame'. The current frame determines
the context used for many debugger commands such as expression
evaluation or source-line listing.

Examples:
+++++++++

::

   backtrace    # Print a full stack trace
   backtrace 2  # Print only the top two entries
   backtrace -1 # Print a stack trace except the initial (least recent) call.
