Entering the Zsh Debugger
****************************

.. toctree::
.. contents::


Invoking the Debugger Initially
===============================

The simplest way to debug your program is to run ``zshdb``. Give
the name of your program and its options and any debugger options:

.. code:: console

        $ cat /etc/profile

        if [ "${PS1-}" ]; then
            if [ "`id -u`" -eq 0 ]; then
              PS1='# '
            else
              PS1='$ '
            fi
          fi
        fi

        if [ -d /etc/profile.d ]; then
          for i in /etc/profile.d/*.sh; do
            if [ -r $i ]; then
              . $i
            fi
          done
          unset i
        fi

        $ zshdb /etc/profile

For help on ``zshdb`` or options, use the ``--help`` option.

.. code:: console

        $ zshdb --help

	Usage:
           zshdb [OPTIONS] <script_file>

        Runs zsh <script_file> under a debugger.

        options:
        ...



Calling the debugger from your program
======================================

Sometimes it is not possible to invoke the program you want debugged
from the ``zshdb``.

Although the debugger tries to set things up to make it look like your
program is called, sometimes the differences matter. Also, once the debugger
is loaded this can slows in parts that you do not want to debug.

So instead, you can add statements into your program to call the
debugger at the spot in the program you want. To do this, you source
``zshdb/dbg-trace.sh`` from where wherever it appears on your filesystem.
This needs to be done only once.

After that you call ``_Dbg_debugger``.

Here is an Example:

.. code:: console

        if [ "${PS1-}" ]; then
          # 15 lines omitted
        fi

        if [ -d /etc/profile.d ]; then
          for i in /etc/profile.d/*.sh; do
            if [ -r $i ]; then
              if [[ $i == "/etc/profile.d/bash_completion.sh"; then
                # Load in debugger
                . /usr/share/bashdb/bashdb-trace -q
                # Call debugger
                _Dbg_debugger
              fi
              . $i
           fi
          done
         unset i
        fi


Until the first call to ``_Dbg_debugger``, there is no debugger overhead.

Note that ``_Dbg_debugger`` causes the statement *after* the call to be stopped.
