.. index:: help
.. _help:

Command Documentation (`help`)
------------------------------

**help** [ *command* [ *subcommand* ]| *expression* ]

Without argument, print the list of available debugger commands.

When an argument is given, it is first checked to see if it is command
name.

Some commands like `info`, `set`, and `show` can accept an
additional subcommand to give help just about that particular
subcommand. For example `help info line` give help about the
`line` subcommand of `info`.

.. seealso::

   :ref:`examine <examine>`.
