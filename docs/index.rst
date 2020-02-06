.. zshdb documentation master file, created by
   sphinx-quickstart on Fri Sep 29 07:09:20 2017.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

zshdb - a gdb-like debugger for zsh
========================================

zshdb is a gdb-like debugger for zsh_.

Since this debugger is similar to other_ trepanning_ debuggers_ and *gdb*
in general, knowledge gained by learning this is transferable to those
debuggers and vice versa.

An Emacs interface is available via realgud_. Visual Studio integration is available from rogalmic via
ZshDebug_.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   features
   install
   entry-exit
   syntax
   commands
   manpage


Indices and tables
==================


* :ref:`genindex`
* :ref:`search`
.. * :ref:`modindex`

.. _zsh: http://www.zsh.org/
.. _other: https://www.npmjs.com/package/trepan-ni
.. _trepanning: https://pypi.python.org/pypi/trepan3k
.. _debuggers: https://metacpan.org/pod/Devel::Trepan
.. _realgud: https://github.com/realgud/realgud
.. _ZshDebug: https://marketplace.visualstudio.com/items?itemName=rogalmic.zsh-debug
