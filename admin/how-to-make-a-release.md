- Let people know of a pending release, e.g. bashdb-zshdb@sourceforge.net;
  no major changes before release, please

- test on lots of platforms.

- Look for patches and outstanding bugs on sourceforge.net


- Edit from configure.ac's release name. E.g.
   ZSHDB_VERSION='0.92'
    AC_INIT([zshdb],[0.92],[rocky@gnu.org])
                       ^^

- ./autogen.sh && make && make check

- Commit changes

  git pull
  git commit -m"Get ready for release ZSHDB_VERSION" .
  make Changelog

- Go over Changelog and add NEWS. Update date of release.

  git commit --amend .

- "make distcheck" should work

- Tag release in git:
   git tag release-${ZSHDB_VERSION}
   git push --tags

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
