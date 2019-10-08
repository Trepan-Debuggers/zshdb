# A Guide to writing test cases

This directory has the more coarse-grain integration tests which work
by running the full debugger. You might also want to check out the
unit tests which handle smaller components of the debugger.

Here is a guide for writing a new test case.

## How integration tests are set up to get run

In general, each integration test case in this directory starts with a file that ends in `.in` like `test-delete.in`.

This is a _zsh_ program however with some text to be substituted based on information in configuration. The text to be substituted is delimited with `@`.

For example, the first shbang or `#!` line looks like this:

```
    #!@SH_PROG@ -f
```

You will see this file listed in `configure.ac`, as a file that is to be used as a template to create the actual shell program that gets run in integration testing.

In `configure` (produced via `configure.ac`) `@SH_PROG@` is substituted with the full path of _zsh_ that is to be run. For example `@SH_PROG@` could be `/bin/zsh` or `/usr/local/bin/zsh`.

The line in `configure.ac` that cause this to happen when `configure` is run looks like this:

```
AC_CONFIG_FILES([test/integration/test-delete],
                [chmod +x test/integration/test-delete])
```

## Anatomy of integration tests.

At a high level, an integration test does these things:

* Unless the test is to be skipped, the test is run under _zshdb_ with some _zshdb_ flags
* the output, possibly filtered, is compared with expected results
* the scripts exits with an exit code based on the results from above:
   - 0 means the test passed
   - 77 indicates a test was skipped
   - anything else is a failure

Let's describe this in more detail. Here is `test-delete.in`:

```
1: #!@SH_PROG@ -f
2: # -*- shell-script -*-
3: t=${0##*/}; TEST_NAME=$t[6,-1]   # basename $0 with 'test-' stripped off
4:
5: [ -z "$builddir" ] && builddir=$PWD
6: . ${builddir}/check-common.sh
7:. run_test_check stepping
```

Line 1: this gets changed into a valid shbang line, like `#!/bin/zsh -f`

Line 2: this is for GNU Emacs to indicate the program is a shell script.

Line 3: pulls out the name of the test so that this can be used to figure out (by default) what zsh script to run a debugger under and what output to compare results with. Here the extracted value is `delete`.

Line 5: get where we are so that we can reference the script to run and the expected results files

Line 6: source in library routines based on the directory set in line 5.

Line 7: runs _zshdb_. The parameter `stepping` the variable portion is the name of the _zsh_ script in `test/example` to run. Here it is `test/example/stepping.sh`. If this parameter were not given we would have used `test/example/delete.sh` because this is was the extracted value in line 3.

Lets look at an example that is slightly (but only slightly) more complicated,
`test-frame.in`:

```
 1: #!@SH_PROG@ -f
 2: # -*- shell-script -*-
 3: t=${0##*/}; TEST_NAME=$t[6,-1]   # basename $0 with 'test-' stripped off
 4:
 5: [ -z "$builddir" ] && builddir=$PWD
 6: . ${builddir}/check-common.sh
 7:
 8: # Doesn't work when not built from the source directory.
 9: [[ "$top_builddir" != "$top_srcdir" ]] && exit 77
10:
11: run_test_check hanoi
```

Line 9 testing whether we should run this script on not.

Finally, let's look at part of a more complicated test case that involves filtering output. This is from `test-setshow.in`:

```
. ${builddir}/check-common.sh
...
cat ${TEST_FILE} | @SED@ -e "s:-x .*/data/setshow\.cmd .*/example/dbg-test2.sh:-x data/setshow.cmd example/dbg-test2.sh:" \
| @SED@ -e 's:record the command history is .*:record the command history is: ' \
> ${TEST_FILTERED_FILE}
check_output $TEST_FILTERED_FILE $RIGHT_FILE
```

Notice we use `@SED@` which is replaced the specific `sed` path that the `configure` finds.

Finally the `check_output` call then gives the name of a filtered file to compare from. The variable `TEST_FILTERED_FILE` is automatically generated when we source `check_common.sh`.
