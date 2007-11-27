"""Best goddamn .pythonrc file in the whole world.

This file is executed when the Python interactive shell is started if
$PYTHONSTARTUP is in your environment and points to this file. It's just
regular Python commands, so do what you will. Your ~/.inputrc file can greatly
complement this file."""

AUTHOR = 'Seth House'
CONTACT = 'seth@eseth.com'
VERSION = '$Rev$'
DATE = '$Date$'

##########################################################################

import sys, os, readline, rlcompleter, atexit, pprint, __builtin__

# Color Support
###############

class TermColors(dict):
    """Gives easy access to ANSI color codes. Attempts to fall back to no color
    for certain TERM values. (Mostly stolen from IPython.)"""

    COLOR_TEMPLATES = (
        ("Black"       , "0;30"),
        ("Red"         , "0;31"),
        ("Green"       , "0;32"),
        ("Brown"       , "0;33"),
        ("Blue"        , "0;34"),
        ("Purple"      , "0;35"),
        ("Cyan"        , "0;36"),
        ("LightGray"   , "0;37"),
        ("DarkGray"    , "1;30"),
        ("LightRed"    , "1;31"),
        ("LightGreen"  , "1;32"),
        ("Yellow"      , "1;33"),
        ("LightBlue"   , "1;34"),
        ("LightPurple" , "1;35"),
        ("LightCyan"   , "1;36"),
        ("White"       , "1;37"),
        ("Normal"      , "0"),
    )

    NoColor = ''
    _base  = '\001\033[%sm\002'

    def __init__(self):
        if os.environ.get('TERM') in ('xterm-color', 'xterm-256color', 'linux',
                                    'screen', 'screen-256color', 'screen-bce'):
            self.update(dict([(k, self._base % v) for k,v in self.COLOR_TEMPLATES]))
        else:
            self.update(dict([(k, self.NoColor) for k,v in self.COLOR_TEMPLATES]))
_c = TermColors()

# Enable a History
##################

HISTFILE="%s/.python-history" % os.environ["HOME"]

# Create the file if it doesn't yet exist
if os.path.exists(HISTFILE):
    readline.read_history_file(HISTFILE)

def savehist():
    readline.write_history_file(HISTFILE)

atexit.register(savehist)

# Enable Color Prompts
######################

sys.ps1 = '%s>>> %s' % (_c['Green'], _c['Normal'])
sys.ps2 = '%s... %s' % (_c['Red'], _c['Normal'])

# Enable Pretty Printing for stdout
###################################

def my_displayhook(value):
    if value is not None:
        __builtin__._ = value
        pprint.pprint(value)
sys.displayhook = my_displayhook

# Welcome message
#################

print """%(Green)s
The Python shell is coming at 'ya, punk!
%(Cyan)s
You've got color, history, and pretty printing.
(If your ~/.inputrc doesn't suck, you've also
got completion and vi-mode keybindings.)
%(Brown)s
Oh yeah, it is that cool.
%(Normal)s""" % _c

atexit.register(lambda: sys.stdout.write("""%(DarkGray)s
Sheesh, I thought he'd never leave. Who invited that guy?
%(Normal)s""" % _c))
