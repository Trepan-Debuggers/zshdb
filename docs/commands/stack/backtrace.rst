.. index:: backtrace
.. _backtrace:

Show call stack (`backtrace`)
-----------------------------

**backtrace** [ *count* ]

Print a stack trace, with the most recent frame first.  With a
positive number, print at most that many entries.  With a negative number
print the top entries minus that number.

An arrow at the begining of a line indicates the 'current frame'. The
current frame determines the context used for many debugger commands
such as expression evaluation or source-line listing.

Examples:
+++++++++

::

   backtrace    # Print a full stack trace
   backtrace 2  # Print only the top two entries
   backtrace -1 # Print a stack trace except the initial (least recent) call.
