.. index:: examine
.. _examine:

Print the value of an expression (`examine`)
--------------------------------------------

**examine** *expr1*

Print value of an expression via typeset, let, and failing these, eval.

Single variables and arithmetic expressions do not need leading ``$`` for
their value is to be substituted. However if neither these, variables
need ``$`` to have their value substituted.

In contrast to normal zsh expressions, expressions should not have
blanks which would cause zsh to see them as different tokens.

Examples:
+++++++++

::

    examine x+1   # ok
    examine x + 1 # not ok

.. seealso::

   :ref:`eval <eval>`.
