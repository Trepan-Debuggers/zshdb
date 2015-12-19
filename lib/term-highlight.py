#!/usr/bin/env python
# from trepan.api import debug
# debug(start_opts={'startup-profile': True})
from __future__ import print_function
import warnings
from pygments import highlight
from pygments.lexers import BashLexer
from pygments.formatters import TerminalFormatter
from pygments.token import Keyword, Name, Comment, String, Error, \
    Number, Operator, Generic, Token, Whitespace
from tempfile import mktemp
from getopt import getopt, GetoptError
import os
import sys

warnings.simplefilter("ignore")

#: Map token types to a tuple of color values for light and dark
#: backgrounds.
TERMINAL_COLORS = {
    Token:              ('',            ''),

    Whitespace:         ('lightgray',   'darkgray'),
    Comment:            ('brown',       'yellow'),
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
    Name.Constant:      ('darkblue',    'yellow'),
    Name.Attribute:     ('teal',        'turquoise'),
    Name.Tag:           ('blue',        'yellow'),
    String:             ('brown',       'lightgray'),
    Number:             ('black',       'yellow'),

    Generic.Deleted:    ('red',        'red'),
    Generic.Inserted:   ('darkgreen',  'green'),
    Generic.Heading:    ('**',         '**'),
    Generic.Subheading: ('*purple*',   '*fuchsia*'),
    Generic.Error:      ('red',        'red'),

    Error:              ('_red_',      '_red_'),
}


def syntax_highlight_file(input_filename, to_stdout=False, bg='light', colors_file=None):
    if to_stdout:
        outfile = sys.stdout
        out_filename = None
    else:
        basename = os.path.basename(input_filename)
        out_filename = mktemp('.term', basename + '_')
        try:
            outfile = open(out_filename, 'w')
        except IOError((errno, strerror)):
            print("I/O in opening debugger output file %s" % out_filename)
            print("error(%s): %s" % (errno, strerror))
            sys.exit(1)
        except:
            print("Unexpected error in opening output file %s" % out_filename)
            sys.exit(1)
            pass
        pass

    if input_filename:
        try:
            infile = open(input_filename)
        except IOError((errno, strerror)):
            print("I/O in opening debugger input file %s" % input_filename)
            print("error(%s): %s" % (errno, strerror))
            sys.exit(2)
        except:
            print("Unexpected error in opening output file %s" % out_filename)
            sys.exit(2)
            pass
        pass
    else:
        infile = sys.stdin
        pass

    formatter = TerminalFormatter(bg=bg)
    if colors_file is not None and os.path.isfile(colors_file):
        try:
            with open(colors_file) as f:
                code = compile(f.read(), colors_file, 'exec')
                exec(code)
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
    if out_filename:
        print(out_filename)
    sys.exit(0)
    pass


def usage():
    program = os.path.basename(__file__)
    print("usage: %s [FILE [--bg {dark|light}] [color-file]]" % program,
          file=sys.stderr)
    sys.exit(2)


def main():
    try:
        opts, args = getopt(sys.argv[1:], "hb:c:", ["help", "bg=", "colors="])
    except GetoptError as err:
        # print help information and exit:
        print(str(err))  # will print something like "option -a not recognized"
        usage()
    dark_light = 'light'
    colors_file = None
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-b", "--bg"):
            if a in ['dark', 'light']:
                dark_light = a
            else:
                assert False, "expecting 'dark' or 'light'; got %s" % a
        elif o in ("-c", "--colors"):
            colors_file = a
        else:
            assert False, "unhandled option %s" % o
        pass
    to_stdout = False
    if len(args) == 0:
        to_stdout = True
        filename = None
    elif len(args) >= 1:
        filename = args[0]
    else:
        sys.exit(3)
        pass
    syntax_highlight_file(filename, to_stdout, bg=dark_light, colors_file=colors_file)
    pass


if __name__ == '__main__':
    main()
    pass
