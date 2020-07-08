.. index:: set; basename
.. _set_basename:

Basename Only in File Paths (`set basename`)
--------------------------------------------

**set basename** [ **on** | **off** ]


Set short filenames in debugger output.

Setting this causes the debugger output to give just the basename for
filenames. This is useful in debugger testing or possibly showing
examples where you don't want to hide specific filesystem and
installation information.

*This command is deprecated since gdb now has ``set filename-display`` which does the same thing.*

So use ``set filename-display``.

.. seealso::

   :ref:`set filename-display <set_filename-display>`, :ref:`show basename <show_basename>`
