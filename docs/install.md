<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [From git](#from-git)
- [Debian/Ubuntu](#debianubuntu)
- [MacOSX](#macosx)

<!-- markdown-toc end -->

# From git

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

# Debian/Ubuntu

On Debian systems, and derivatives, zshdb can be installed by running:

```console
    sudo apt-get install zshdb
```

The latest version may not yet be included in the archives. If you are running
a stable version of Debian or a derivative, you may need to install zshdb from
the backports repository for your version to get a recent version installed.

# MacOSX

On OSX systems, you can install from Homebrew

```console
    brew install zshdb
```
