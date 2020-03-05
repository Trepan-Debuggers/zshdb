.. index:: set; style
.. _set_style:

Set whether to use Pygments in Formating Listings (`set style`)
---------------------------------------------------------------

**set style** [*pygments-style*]

Set the pygments style in to use in formatting text for a 256-color terminal.
Note: if your terminal doesn't support 256 colors, you may be better off
using `--highlight=plain` or `--highlight=dark` instead. To turn off styles
use `set style none`.

To list the available pygments styles inside the debugger, omit the style name.


Examples:
+++++++++

::

    set style monokai # use monokai style (a dark style)
    set style         # list all known pygments styles
    set style off     # turn off any pygments source mark up

.. seealso::

   :ref:`show style <show_style>` and :ref:`set highlight <set_highlight>`
