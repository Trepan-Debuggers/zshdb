.. _list:

List (show me the code!)
------------------------

**list** [*module] [ *first* [ *num* ]]

**list** *location* [*num*]

List source code.

Without arguments, print lines centered around the current line. If
*num* is given that number of lines is shown.

If this is the first `list` command issued since the debugger command
loop was entered, then the current line is the current frame. If a
subsequent list command was issued with no intervening frame changing,
then that is start the line after we last one previously shown.

A *location* is either:

* a number, e.g. 5,
* a function, e.g. `join` or `os.path.join`
* a module, e.g. os or os.path
* a filename, colon, and a number, e.g. `foo.py:5`,
* a module name and a number, e.g,. `os.path:5`.
* a "." for the current line number
* a "-" for the lines before the current linenumber

If the location form is used with a subsequent parameter, the
parameter is the starting line number is used. When there two numbers
are given, the last number value is treated as a stopping line unless
it is less than the start line, in which case it is taken to mean the
number of lines to list instead.

Wherever a number is expected, it does not need to be a constant --
just something that evaluates to a positive integer.

Examples:
+++++++++

::

    list 5            # List starting from line 5
    list 4+1          # Same as above.
    list foo.py:5     # List starting from line 5 of foo.py
    list os.path:5    # List starting from line 5 of os.path
    list os.path 5    # Same as above.
    list os.path 5 6  # list lines 5 and 6 of os.path
    list os.path 5 2  # Same as above, since 2 < 5.
    list foo.py:5 2   # List two lines starting from line 5 of foo.py
    list os.path.join # List lines around the os.join.path function.
    list .            # List lines centered from where we currently are stopped
    list -            # List lines previous to those just shown

.. seealso::

   :ref:`set listize <set_listsize>`, or :ref:`show listsize <show_listsize>` to see or set the number of source-code lines to list.
