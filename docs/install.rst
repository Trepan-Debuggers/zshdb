How to install
****************

.. toctree::


From a Package
----------------

Repology_ maintains a list of various bundled `zshdb` packages. Below are some specific distributions that contain `zshdb`.

At the time this documentation was built, here is status that they provide:

|packagestatus|

Check the link above for more up-to-date information.


.. |packagestatus| image:: https://repology.org/badge/vertical-allrepos/zshdb.svg
		 :target: https://repology.org/project/zshdb/versions


Debian/Ubuntu
+++++++++++++++

On Debian systems, and derivatives, `zshdb` can be installed by running:

.. code:: console

    $ sudo apt-get install zshdb


The latest version may not yet be included in the archives. If you are running
a stable version of Debian or a derivative, you may need to install `zshdb` from
the backports repository for your version to get a recent version installed.

MacOSX
+++++++

On OSX systems, you can install from Homebrew or MacPorts_.

.. code:: console

    $  brew install zshdb


From Source
------------

SourceForge
++++++++++++

Go to sourceforge_ and find the most recent version and download a tarball of that.


.. code:: console

    $ tar -xpf zshdb-xxx.tar.bz2
    $ cd zshdb-xxx
    $ ./autogen.sh
    $ make && make test
    $ make install # may need sudo



git
+++


Many package managers have back-level versions of this debugger. The most recent versions is from the github_.

To install from git:

.. code:: console

        $ git clone git://github.com/rocky/zshdb.git
        $ cd zshdb
        $ ./autogen.sh  # Add configure options. See ./configure --help


If you've got a suitable `zsh` installed, then

.. code:: console

        $ make && make test


To try on a real program such as perhaps `/etc/zsh/zshrc`:

.. code:: console

      $ ./zshdb -L /etc/zsh/zshrc # substitute .../zshrc with your favorite zsh script

To modify source code to call the debugger inside the program:

.. code:: console

    source path-to-zshdb/zshdb/dbg-trace.sh
    # work, work, work.

    _Dbg_debugger
    # start debugging here


Above, the directory *path-to_zshdb* should be replaced with the
directory that `dbg-trace.sh` is located in. This can also be from the
source code directory *zshdb* or from the directory `dbg-trace.sh` gets
installed directory. The "source" command needs to be done only once
somewhere in the code prior to using `_Dbg_debugger`.

If you are happy and `make test` above worked, install via:

.. code:: console

    sudo make install


and uninstall with:

.. code:: console

    $ sudo make uninstall # ;-)


.. _MacPorts: https://ports.macports.org/port/zshdb/summary
.. _Repology: https://repology.org/project/zshdb/versions
.. _github: https://github.com/rocky/zshdb
.. _sourceforge: https://sourceforge.net/projects/bashdb/files/zshdb/
