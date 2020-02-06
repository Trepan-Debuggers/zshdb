- Let people know of a pending release?

- test on lots of platforms.

- Look for patches and outstanding bugs

- git pull

- Edit from `configure.ac`'s release name. If we have this in `configure.ac`:
```
   AC_INIT([zshdb],[1.1.3],[rocky@gnu.org])
                    ^^^^^^
```

then:

```console
   $ export ZSHDB_VERSION='1.1.3'
   $ ./autogen.sh && make && make check
```

- Commit changes:

```console
  $ git commit -m"Get ready for release $ZSHDB_VERSION" .
  $ make Changelog
```

- Go over ChangeLog and add to `NEWS.md`. Update date of release.

  ```console
	$  git commit --amend .
  ```

- `make distcheck` should work

- Tag release on github
   https://github.com/rocky/zshdb/releases

- Get onto sourceforge https://sourceforge.net/projects/bashdb/files/zshdb/:

  Use the GUI
   login, file release, add folder $ZSHDB_VERSION
   hit upload button.
   copy NEWS.md as README.md in $ZSHDB_VERSION

- Update link in github/rocky.github.com/zshdb/index.html

- Redo packages?

- Bump version in configure.ac and add "dev". See place above in
  removal
