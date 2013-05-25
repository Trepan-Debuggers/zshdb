#!/usr/bin/env python
# -*- coding: utf-8 -*-
#   Copyright (C) 2013 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''Pygments-related terminal formatting'''

import re
from pygments                     import highlight, lex
from pygments.console             import ansiformat
from pygments.filter              import Filter
from pygments.formatter           import Formatter
from pygments.formatters          import TerminalFormatter
from pygments.formatters.terminal import TERMINAL_COLORS
from pygments.lexers              import RstLexer
from pygments.token               import *
from pygments.util                import get_choice_opt
import getopt, sys

def format_token(ttype, token, colorscheme=TERMINAL_COLORS,
                 highlight='light' ):
    if 'plain' == highlight: return token
    light_bg = 'light' == highlight

    color = colorscheme.get(ttype)
    if color:
        color = color[light_bg]
        return ansiformat(color, token)
        pass
    return token

Arrow      = Name.Variable
Compare    = Name.Exception
Const      = String
Filename   = Comment.Preproc
Function   = Name.Function
Label      = Operator.Word
LineNumber = Number
Offset     = Operator
Opcode     = Name.Function
Return     = Operator.Word
Var        = Keyword
Verbatim   = String

color_scheme = TERMINAL_COLORS.copy()
color_scheme[Generic.Strong] = ('*black*', '*white*')
color_scheme[Name.Variable]  = ('_black_', '_white_')
color_scheme[Generic.Emph]   = TERMINAL_COLORS[Comment.Preproc]

# Should come last since "Name" is used above
Name = Comment.Preproc

class RstFilter(Filter):

    def __init__(self, **options):
        Filter.__init__(self, **options)
        pass

    def filter(self, lexer, stream):
        for ttype, value in stream:
            if ttype is Token.Name.Variable:
                value = value[1:-1]
                pass
            if ttype is Token.Generic.Emph:
                type
                value = value[1:-1]
                pass
            elif ttype is Token.Generic.Strong:
                value = value[2:-2]
                pass
            yield ttype, value
            pass
        return
    pass

class RSTTerminalFormatter(Formatter):
    r"""
    Format tokens with ANSI color sequences, for output in a text console.
    Color sequences are terminated at newlines, so that paging the output
    works correctly.

    The `get_style_defs()` method doesn't do anything special since there is
    no support for common styles.

    Options accepted:

    `bg`
        Set to ``"light"`` or ``"dark"`` depending on the terminal's background
        (default: ``"light"``).

    `colorscheme`
        A dictionary mapping token types to (lightbg, darkbg) color names or
        ``None`` (default: ``None`` = use builtin colorscheme).
    """
    name = 'Terminal'
    aliases = ['terminal', 'console']
    filenames = []

    def __init__(self, **options):
        Formatter.__init__(self, **options)
        self.darkbg = get_choice_opt(options, 'bg',
                                     ['light', 'dark'], 'light') == 'dark'
        self.colorscheme = options.get('colorscheme', None) or TERMINAL_COLORS
        self.width = options.get('width', 80)
        self.verbatim = False
        self.in_list  = False
        self.column   = 1
        self.last_was_nl = False
        return

    def reset(self, width=None):
        self.column = 0
        if width: self.width = width
        return

    def format(self, tokensource, outfile):
        # hack: if the output is a terminal and has an encoding set,
        # use that to avoid unicode encode problems
        if not self.encoding and hasattr(outfile, "encoding") and \
           hasattr(outfile, "isatty") and outfile.isatty() and \
           sys.version_info < (3,):
            self.encoding = outfile.encoding
            pass
        self.outfile = outfile
        return Formatter.format(self, tokensource, outfile)

    def write_verbatim(self, text):
        # If we are doing color, then change to the verbatim
        # color
        if self.__class__ != MonoRSTTerminalFormatter:
            cs = self.colorscheme.get(Verbatim)
            color = cs[self.darkbg]
        else:
            color = None
            pass
        return self.write(text, color)

    def write(self, text, color):
        color_text = text
        if color: color_text = ansiformat(color, color_text)
        self.outfile.write(color_text)
        self.column += len(text)
        return self.column

    def write_nl(self):
        self.outfile.write('\n')
        self.column = 0
        return self.column


    def reflow_text(self, text, color):
        # print '%r' % text
        # from trepan.api import debug
        # if u' or ' == text: debug()

        last_last_nl = self.last_was_nl
        if text[-1] == '\n':
            if self.last_was_nl:
                self.write_nl()
                self.write_nl()
                text = text[:-1]
            elif self.verbatim:
                self.write_verbatim(text)
                self.column = 0
                self.verbatim = False
                self.last_was_nl = True
                return
            else:
                self.write(' ', color)
                text = text[:-1]
                pass
            self.last_was_nl = True
            if '' == text: return
            while text[-1] == '\n':
                self.write_nl()
                text = text[:-1]
                if '' == text: return
                pass
            pass
        else:
            self.last_was_nl = False
            pass
        self.in_list = False
        if last_last_nl:
            if ' * ' == text[0:3]: self.in_list = True
            elif '  ' == text[0:2]: self.verbatim = True
            pass

        # FIXME: there may be nested lists, tables and so on.
        if self.verbatim:
            self.write_verbatim(text)
        elif self.in_list:
            # FIXME:
            self.write(text, color,)
        else:
            words = re.compile('[ \t]+').split(text)
            for word in words[:-1]:
                # print "column: %d, word %s %d" % (self.column, word, self.width)
                if (self.column + len(word) + 1) >= self.width:
                    self.write_nl()
                    pass
                if not (self.column == 0 and word == ''):
                    self.write(word + ' ', color)
                    pass
                pass
            if words[-1]:
                # print "column2: %d, word %r" % (self.column, words[-1])
                if (self.column + len(words[-1])) >= self.width:
                    self.write_nl()
                    pass
                self.write(words[-1], color)
                pass
            pass
        return


    def format_unencoded(self, tokensource, outfile):
        for ttype, text in tokensource:
            color = self.colorscheme.get(ttype)
            while color is None:
                ttype = ttype[:-1]
                color = self.colorscheme.get(ttype)
                pass
            if color: color = color[self.darkbg]
            self.reflow_text(text, color)
            pass
        return
    pass

class MonoRSTTerminalFormatter(RSTTerminalFormatter):
    def format_unencoded(self, tokensource, outfile):
        for ttype, text in tokensource:
            if ttype is Token.Name.Variable:
                text = '"%s"' % text
                pass
            elif ttype is Token.Generic.Emph:
                type
                text = "*%s*" % text
                pass
            elif ttype is Token.Generic.Strong:
                text = text.upper()
                pass
            pass

            self.reflow_text(text, None)
            pass
        return
    pass

class MonoTerminalFormatter(TerminalFormatter):
    def format_unencoded(self, tokensource, outfile):
        for ttype, text in tokensource:
            if ttype is Token.Name.Variable:
                text = '"%s"' % text
                pass
            elif ttype is Token.Generic.Emph:
                type
                text = "*%s*" % text
                pass
            elif ttype is Token.Generic.Strong:
                text = text.upper()
                pass
            pass

            outfile.write(text)
            pass
        return
    pass

rst_lex = RstLexer()
rst_filt = RstFilter()
rst_lex.add_filter(rst_filt)
color_tf = RSTTerminalFormatter(colorscheme=color_scheme)
mono_tf  = MonoRSTTerminalFormatter()

def rst_text(text, mono, width=80):
    if mono:
        tf = mono_tf
    else:
        tf = color_tf
        pass
    tf.reset(width)
    return highlight(text, rst_lex, tf)

def rst_format(text, width=None, mono=None):
    if width is None or width == '':
        width = os.environ['COLUMNS']
        pass
    try:
        width = int(width)
    except:
        width = 80
        pass
    if mono:
        tf = mono_tf
    else:
        tf = color_tf
        pass
    tf.reset(width)
    print tf.width
    print(highlight(text, rst_lex, tf))
    pass

def main(args):
    opts, args = getopt.getopt(sys.argv[1:], 'w:')
    if len(args) != 1:
        print("Expected a single text argument; got %d tokens" % len(sys.argv[0]))
        print("Usage: rest.py [-w] text")
        sys.exit(1)
        pass
    if len(opts) == 1:
        width = opts[0][1]
    else:
        width = None
        pass
    return rst_format(args[0], width)

if __name__ == '__main__':
    main(sys.argv)
    pass
