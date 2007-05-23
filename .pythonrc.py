# ~/.pythonrc.py

# Enable Completion & Readline Support {{{1

try:
    import readline
except ImportError:
    print "Module readline not available."
else:
    import rlcompleter

readline.parse_and_bind("tab: complete")
# readline.parse_and_bind("tab: menu-complete")

# Enable a History {{{1

import os
histfile="%s/.python-history" % os.environ["HOME"]
readline.read_history_file(histfile)

def savehist():
   global histfile
   readline.write_history_file(histfile)

import atexit
atexit.register(savehist)

# Enable Color Prompts {{{1

import sys,os
# if os.environ.get( 'TERM' ) in [ 'xterm', 'vt100' ]:
sys.ps1 = '\001\033[0:1;32m\002>>> \001\033[0m\002'
sys.ps2 = '\001\033[0:31m\002... \001\033[0m\002'

# Add ls and cd Commands {{{1

import sys, os, os.path
class DirLister:

    def __getitem__(self, key):
        s =  os.listdir(os.getcwd())
        return s[key]

    def __getslice__(self,i,j):
        s =  os.listdir(os.getcwd())
        return s[i:j]

    def __call__(self, path=os.getcwd()):
        path = os.path.expanduser(os.path.expandvars(path))
        return os.listdir(path)

    def __repr__(self):
        return str(os.listdir(os.getcwd()))


class DirChanger:
    def __init__(self, path=os.getcwd()):
        self.__call__(path)

    def __call__(self, path=os.getcwd()):
        path = os.path.expanduser(os.path.expandvars(path))
        os.chdir(path)

    def __repr__(self):
        return os.getcwd()


ls = DirLister()
cd = DirChanger()

# Other Common Imports {{{1

import datetime
import re

# Setup Commonly Worked-On Django Paths {{{1

try:
    import ffc_website
except ImportError:
    pass

# Welcome message {{{1

print "\nWelcome to the Python shell, bitches! You've got readline with Vi-mode keybindings. Glee! B-)\n"
# Python Console with an editable buffer. {{{1
# Seems to need to be last in this file.

import os
from tempfile import mkstemp
from code import InteractiveConsole

EDITOR = os.environ.get('EDITOR', 'vim')
EDIT_CMD = '\e'

class EditableBufferInteractiveConsole(InteractiveConsole):
    def __init__(self, *args):
        self.last_buffer = [] # This holds the last executed statement
        InteractiveConsole.__init__(self, *args)

    def runsource(self, source, *args):
        self.last_buffer = [ source ]
        return InteractiveConsole.runsource(self, source, *args)

    def raw_input(self, *args):
        line = InteractiveConsole.raw_input(self, *args)
        if line == EDIT_CMD:
            fd, tmpfl = mkstemp('.py')
            os.write(fd, '\n'.join(self.last_buffer))
            os.close(fd)
            os.system('%s %s' % (EDITOR, tmpfl))
            line = open(tmpfl).read()
            os.unlink(tmpfl)
            tmpfl = ''
            # needed for multiple lines???
            # lines = line.split( '\n' )
            # for i in range(len(lines) - 1): self.push( lines[i] )
            # line = lines[-1]
        return line

c = EditableBufferInteractiveConsole()
c.write("""
Starting the editable interactive console.
Edit command is '%s'.

""" % EDIT_CMD)
c.interact(banner='')

