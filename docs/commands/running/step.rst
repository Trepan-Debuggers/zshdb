.. index:: step
.. _step:

Step Into (`step`)
------------------

**step** [ **+** | **-** [ *count* ]]

Single step a statement. This is sometimes called 'step into'.

If *count* is given, stepping occurs that many times before
stopping. Otherwise *count* is one. *count* an be an arithmetic
expression.

If suffix \"+\" is added, we ensure that the file and line position is
different from the last one just stopped at.

However in contrast to \"next\", functions and source'd files are stepped
into.

If suffix \"-\" is added, the different line aspect of \"step+\" does not occur.

With no suffix given, the behavior is dictated by the setting of **set different**.

Examples:
+++++++++

::

    step        # step 1
    step 1      # same as above
    step 5/5+0  # same as above

.. seealso::

   :ref:`next <next>` command. :ref:`skip <skip>`, and :ref:`continue <continue>` provide other ways to progress execution.
    :ref:`set different <set_different>` sets the default stepping behavior.
