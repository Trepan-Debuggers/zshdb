.. index:: step
.. _step:

Step Into (`step`)
------------------

**step** [ **+** | **-** | **<** | **>** | **!** ] [*event* ...] [ *count* ]

Execute the current line, stopping at the next event.

With an integer argument, step that many times.

*event* is list of an event name which is one of: `call`,
`return`, `line`, `exception` `c-call`, `c-return` or `c-exception`.
If specified, only those stepping events will be considered. If no
list of event names is given, then any event triggers a stop when the
count is 0.

There is however another way to specify a *single* event, by
suffixing one of the symbols `<`, `>`, or `!` after the command or on
an alias of that.  A suffix of `+` on a command or an alias forces a
move to another line, while a suffix of `-` disables this requirement.
A suffix of `>` will continue until the next call. (`finish` will run
run until the return for that call.)

If no suffix is given, the debugger setting `different-line`
determines this behavior.

Examples:
+++++++++

::

    step        # step 1 event, *any* event
    step 1      # same as above
    step 5/5+0  # same as above
    step line   # step only line events
    step call   # step only call events
    step>       # same as above
    step call line # Step line *and* call events

.. seealso::

   :ref:`next <next>` command. :ref:`skip <skip>`, and :ref:`continue <continue>` provide other ways to progress execution.
