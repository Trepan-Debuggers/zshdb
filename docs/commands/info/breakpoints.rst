.. index:: info; breakpoints
.. _info_breakpoints:

Info Breakpoints
----------------

**info breakpoints** [ *bp-number...* ]

Show status of user-settable breakpoints. If no breakpoint numbers are
given, the show all breakpoints. Otherwise only those breakpoints
listed are shown and the order given.

The columns in a line show are as follows:

* The \"Num\" column is the breakpoint number which can be used in `condition`, `delete`, `disable`, `enable` commands.
* The \"Disp\" column contains one of \"keep\", \"del\", the disposition of the breakpoint after it gets hit.
* The \"enb\" column indicates whether the breakpoint is enabled.
* The \"Where\" column indicates where the breakpoint is located.

Example:
++++++++

::

   zshdb<4> info breakpoints
   Num Type       Disp Enb What
   1   breakpoint keep n   /etc/profile:8
   2   breakpoint keep y   /etc/profile:10
       stop only if [[ ${PS1-} ]]


Show breakpoints.

.. seealso::

   :ref:`break <break>`, :ref:`condition <condition>`, :ref:`delete <delete>`, :ref:`enable <enable>`, and ref:`disable <disable>`
