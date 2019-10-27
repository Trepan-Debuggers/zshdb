- Let people know of a pending release?

- test on lots of platforms.

- Look for patches and outstanding bugs on sourceforge.net

- git pull

- Edit from configure.ac's release name. E.g.
   export ZSHDB_VERSION='1.1.0'
    AC_INIT([zshdb],[1.1.0],[rocky@gnu.org])
                     ^^^^^

- ./autogen.sh && make && make check

- Commit changes

  git commit -m"Get ready for release $ZSHDB_VERSION" .
  make Changelog

- Go over ChangeLog and add NEWS. Update date of release.

  git commit --amend .

- "make distcheck" should work

- Tag release on github
   https://github.com/rocky/zshdb/releases

- Get onto sourceforge:
  Use the GUI

  Use the GUI
   login, file release, add folder $ZSHDB_VERSION
   hit upload button.
   copy NEWS as README in $ZSHDB_VERSION

- Update link in github/rocky.github.com/zshdb/index.html

- Redo packages?

- Bump version in configure.ac and add "dev". See place above in
  removal
