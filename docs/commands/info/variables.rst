.. index:: info; variables
.. _info_variables:

Info Variables
----------------

**info variables** [*property*]

list global and static variable names.

Variable lists by property.
*property* is an abbreviation of one of:

* arrays,
* exports,
* fixed,
* floats,
* functions,
* hash,
* integers, or
* readonly

Examples:
+++++++++

::

    info variables             # show all variables
    info variables readonly    # show only read-only variables
    info variables integer     # show only integer variables
    info variables functions   # show only functions
