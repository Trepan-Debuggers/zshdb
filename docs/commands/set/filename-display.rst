.. index:: set; filename-display
.. _set_filename-display:

How to display file names (`set filename-display`)
--------------------------------------------------

**set filename-display** [ **basename** | **absolute** ]

Set how to display filenames.

Setting this causes the debugger output to either the basename for
filenames or its full absolute path.

The absolute path is useful in debugger testing or possibly showing
examples where you don't want to hide specific filesystem and
installation information.

.. seealso::

   :ref:`show filename-display <show_filename-display>`
