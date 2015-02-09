[![Build Status](https://travis-ci.org/rocky/zshdb.png)](https://travis-ci.org/rocky/zshdb)

*zshdb* is debugger for zsh scripts. It started as a port of my bash
debugger [bashdb](http://bashdb.sf.net) so the commands used in
both are similar.

The command syntax generally follows that of the trepanning debuggers
and, more generally, GNU debugger *gdb*.

To install from git:

```console
    git-clone git://github.com/rocky/zshdb.git
    cd zshdb
    ./autogen.sh  # Add configure options. See ./configure --help
```

If you've got a suitable zsh installed, then

```console
    make && make test
```

To try on a real program such as perhaps `/etc/zsh/zshrc`:

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

See the [wiki](https://github.com/rocky/zshdb/wiki) for more information.

Rocky Bernstein <rocky@gnu.org>
