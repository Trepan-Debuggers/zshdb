.. index:: eval
.. _eval:

Evaluate a Zsh Expression (`eval`)
----------------------------------

**eval** *cmd*

**eval**

**eval?**

In the first form *cmd* is a string; *cmd* is a string sent to special
shell builtin *eval*.

In the second form, use evaluate the current source line text.

Often when one is stopped at the line of the first part of an "if", "elif", "case", "return",
"while" compound statement or an assignment statement, one wants to eval is just the expression
portion. For this, use eval?. Actually, any alias that ends in ? which is aliased to eval will
do thie same thing.

Run *cmd* in the context of the current frame.

If no string is given, we run the string from the current source code
about to be run. If the command ends `?` (via an alias) and no string is
given, the following translations occur:

::

   {if|elif} <expr> [; then] => <expr>
   while <expr> [; do]?      => <expr>
   return <expr>             => <expr>
   <var>=<expr>              => <expr>

The above is done via regular expression matching. No fancy parsing is
done, say, to look to see if *expr* is split across a line or whether
var an assignment might have multiple variables on the left-hand side.

Examples:
+++++++++

::

    eval 1+2  # 3
    eval      # Run current source-code line
    eval?     # but strips off leading 'if', 'while', ..
              # from command

.. seealso::

   :ref:`set autoeval <set_autoeval>` and :ref:`examine <examine>`.
