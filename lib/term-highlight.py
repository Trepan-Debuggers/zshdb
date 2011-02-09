#!/usr/bin/env python
# from pydbgr.api import debug
# debug()
from pygments import highlight
from pygments.lexers import BashLexer
from pygments.formatters import TerminalFormatter
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Token, Whitespace
from tempfile import mktemp
import os, sys

#: Map token types to a tuple of color values for light and dark
#: backgrounds.
TERMINAL_COLORS = {
    Token:              ('',            ''),

    Whitespace:         ('lightgray',   'darkgray'),
    Comment:            ('brown',       'darkgray'),
    Comment.Preproc:    ('teal',        'turquoise'),
    Keyword:            ('*darkgreen*',  'blue'),
    Keyword.Type:       ('teal',        'turquoise'),
    Operator.Word:      ('purple',      'fuchsia'),
    Name.Builtin:       ('teal',        'turquoise'),
    Name.Function:      ('darkgreen',   'green'),
    Name.Namespace:     ('_teal_',      '_turquoise_'),
    Name.Class:         ('_darkgreen_', '_green_'),
    Name.Exception:     ('teal',        'turquoise'),
    Name.Decorator:     ('darkgray',    'lightgray'),
    Name.Variable:      ('darkblue',    'blue'),
    Name.Constant:      ('darkblue',    'blue'),
    Name.Attribute:     ('teal',        'turquoise'),
    Name.Tag:           ('blue',        'blue'),
    String:             ('brown',       'brown'),
    Number:             ('black',       'blue'),

    Generic.Deleted:    ('red',        'red'),
    Generic.Inserted:   ('darkgreen',  'green'),
    Generic.Heading:    ('**',         '**'),
    Generic.Subheading: ('*purple*',   '*fuchsia*'),
    Generic.Error:      ('red',        'red'),

    Error:              ('_red_',      '_red_'),
}


def syntax_highlight_file(input_filename, to_stdout = False, color_file=None):
    if to_stdout:
        outfile = sys.stdout
        out_filename = None
    else:
        basename = os.path.basename(input_filename)
        out_filename=mktemp('.term', basename + '_')
        try:
            outfile = open(out_filename, 'w')
        except IOError, (errno, strerror):
            print "I/O in opening debugger output file %s" % out_filename
            print "error(%s): %s" % (errno, strerror)
            sys.exit(1)
        except:
            print "Unexpected error in opening output file %s" % out_filename
            sys.exit(1)
            pass
        pass

    if input_filename:
        try:
            infile = open(input_filename)
        except IOError, (errno, strerror):
            print "I/O in opening debugger input file %s" % input_filename
            print "error(%s): %s" % (errno, strerror)
            sys.exit(2)
        except:
            print "Unexpected error in opening output file %s" % out_filename
            sys.exit(2)
            pass
        pass
    else:
        infile = sys.stdin
        pass

    formatter = TerminalFormatter()
    if color_file and os.path.isfile(color_file):
        try:
            execfile(color_file)
        except:
            sys.exit(10)
            pass
        pass
    formatter.colorscheme = TERMINAL_COLORS
    for code_line in infile.readlines():
        line = highlight(code_line, BashLexer(), formatter).strip("\r\n")
        outfile.write(line + "\n")
        # print line,
        pass
    outfile.close
    if out_filename: print out_filename
    sys.exit(0)
    pass

if __name__=='__main__':
    color_file = None
    to_stdout = False
    if len(sys.argv) == 1:
        to_stdout = True
        filename = None
    elif len(sys.argv) == 2:
        filename = sys.argv[1]
    elif len(sys.argv) == 3:
        filename = sys.argv[1]
        color_file = sys.argv[2]
    else:
        print "usage: $0 [FILE [color-file]]"
        sys.exit(3)
        pass
    syntax_highlight_file(filename, to_stdout, color_file)
    pass
