#!/usr/bin/env python
# from trepan.api import debug
# debug()
import warnings
warnings.simplefilter("ignore")
from pygments import highlight
from pygments.lexers import BashLexer
from pygments.formatters import TerminalFormatter
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Token, Whitespace
from tempfile import mktemp
from getopt import getopt
import os, sys

#: Map token types to a tuple of color values for light and dark
#: backgrounds.
TERMINAL_COLORS = {
    Token:              ('',            ''),

    Whitespace:         ('lightgray',   'darkgray'),
    Comment:            ('brown',       'brown'),
    Comment.Preproc:    ('teal',        'turquoise'),
    Keyword:            ('*darkgreen*',  'turquoise'),
    Keyword.Type:       ('teal',        'turquoise'),
    Operator.Word:      ('purple',      'fuchsia'),
    Name.Builtin:       ('teal',        'turquoise'),
    Name.Function:      ('darkgreen',   'green'),
    Name.Namespace:     ('_teal_',      '_turquoise_'),
    Name.Class:         ('_darkgreen_', '_green_'),
    Name.Exception:     ('teal',        'turquoise'),
    Name.Decorator:     ('darkgray',    'lightgray'),
    Name.Variable:      ('darkblue',    'green'),
    Name.Constant:      ('darkblue',    'orange'),
    Name.Attribute:     ('teal',        'turquoise'),
    Name.Tag:           ('blue',        'orange'),
    String:             ('brown',       'brown'),
    Number:             ('black',       'orange'),

    Generic.Deleted:    ('red',        'red'),
    Generic.Inserted:   ('darkgreen',  'green'),
    Generic.Heading:    ('**',         '**'),
    Generic.Subheading: ('*purple*',   '*fuchsia*'),
    Generic.Error:      ('red',        'red'),

    Error:              ('_red_',      '_red_'),
}


def syntax_highlight_file(input_filename, to_stdout = False, bg='light', colors_file=None):
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

    formatter = TerminalFormatter(bg=bg)
    if colors_file is not None and os.path.isfile(colors_file):
        try:
            execfile(colors_file)
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

def main():
    try:
        opts, args = getopt(sys.argv[1:], "hb:", ["help", "bg="])
    except GetoptError as err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    output = None
    verbose = False
    dark_light = 'light'
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-b", "--bg"):
            if a in ['dark', 'light']:
                dark_light = a
            else:
                assert False, "expecting 'dark' or 'light'; got %s" % a
        else:
            assert False, "unhandled option"
        pass
    colors_file = None
    to_stdout = False
    if len(args) == 0:
        to_stdout = True
        filename = None
    elif len(args) == 1:
        filename = args[0]
    elif len(args) == 2:
        filename = args[0]
        colors_file = args[1]
    else:
        print "usage: $0 [FILE [--bg {dark|light}] [color-file]]"
        sys.exit(3)
        pass
    syntax_highlight_file(filename, to_stdout, bg=dark_light, colors_file=colors_file)
    pass


if __name__=='__main__':
    main()
    pass
