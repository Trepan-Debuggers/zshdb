.. index:: set; autoeval
.. _set_autoeval:

Auto-Evaluation of Unrecognized Debugger Commands (`set auto eval`)
-------------------------------------------------------------------

**set autoeval** [ **on** | **off** ]

Evaluate unrecognized debugger commands.

Often inside the debugger, one would like to be able to run arbitrary
zsh commands without having to preface expressions with
``print`` or ``eval``. Setting *autoeval* on will cause unrecognized
debugger commands to be *eval*'d as a zsh expression.

Note that if this is set, on error the message shown on type a bad
debugger command changes from:

::

      Undefined command: "fdafds". Try "help".

to something more zsh-eval-specific such as:

::

      /tmp/zshdb_eval_26397:2: command not found: fdafds


.. seealso::

   :ref:`show autoeval <show_autoeval>`
