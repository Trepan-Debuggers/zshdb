[![Build Status](https://travis-ci.org/rocky/zshdb.png)](https://travis-ci.org/rocky/[zshdb])

Introduction
============

This is a port and cleanup of my bash debugger [bashdb](http://bashdb.sf.net).

The command syntax generally follows that of the GNU debugger *gdb*.

However this debugger depends on a number of bug fixes and of debugging
support features that are neither part of the POSIX 1003.1 standard
and are not in current "stable" *zsh* releases. In particular, the
"functrace" function should always report filenames and absolute line
numbers.  Also both "functrace" and "funcstack" should include
source'd files in their arrays.

Setup
-----

To get the code, install git and run in a zsh shell:

```console
    git-clone git://github.com/rocky/zshdb.git
    cd zshdb
    ./autogen.sh  # Add configure options. See ./configure --help
```

If you've got a suitable zsh installed, then

```console
    make && make test
```

To try on a real program such as perhaps /etc/zsh/zshrc:

```shell
    ./zshdb /etc/zsh/zshrc # substitute .../zshrc with your favorite zsh script
```

To modify source code to call the debugger inside the program:

```shell
    source path-to-zshdb/zshdb/dbg-trace.sh
    # work, work, work.

    _Dbg_debugger
    # start debugging here
```

Above, the directory *path-to_zshdb* should be replaced with the
directory that `dbg-trace.sh` is located in. This can also be from the
source code directory *zshdb* or from the directory `dbg-trace.sh` gets
installed directory. The "source" command needs to be done only once
somewhere in the code prior to using `_Dbg_debugger`.

If you are happy and `make test` above worked, install via:

```console
    sudo make install
```

and uninstall with:

```console
    sudo make uninstall # ;-)
```

See INSTALL for generic configure installation instructions.

What's here, What's not, and Why not?
-------------------------------------

What's missing falls into two categories:

* Stuff that can be ported in a straightforward way from *bashdb*
* Stuff that needs additional zsh support

Of the things which can be ported in a straight-forward way, however
some of them I want to revise and simplify. In some cases, the fact
that *zsh* has associative arrays simplifies code. On other cases, the
code I wrote needs refactoring and better modularization.

Writing documentation is important, but an extensive guide will have
to wait. For now one can consult the reference guide that comes with
bashdb: http://bashdb.sf.net/bashdb.html There is some minimal help to
get a list of commands and some help for each.

What's not here in more detail
------------------------------

**Showing frame arguments**

This can be done with or without support from *zsh*, albeit faster with
help from *zsh*. Changing scope when changing frames however has to be
done with *zsh* support.

**Setting $0**

**other stuff including...**

* signal handling,
* debugger commands:
  *  debug
  *  file
  *  handle
  *  history
  *  pwd
  *  signal
  *  tty
  *  watch

  None of this is rocket science. Should be pretty straight-forward to
  add.

What may need more work and support from zsh
---------------------------------------------

Stopping points that can be used for breakpoint
