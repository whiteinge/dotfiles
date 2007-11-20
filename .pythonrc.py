"""This file is executed when the Python interactive shell is started if
$PYTHONSTARTUP is in your environment and points to this file. It's just
regular Python commands, so do what you will!"""

import sys, os, readline, rlcompleter, atexit

GREEN = '\001\033[0:1;32m\002'
RED = '\001\033[0:31m\002'
NORMAL = '\001\033[0m\002'

HISTFILE="%s/.python-history" % os.environ["HOME"]

# Enable Completion & Readline Support
######################################

# These are better defined in your .inputrc
# readline.parse_and_bind('tab: complete')
# readline.parse_and_bind("tab: menu-complete")

# Enable a History
##################

# Create the file if it doesn't yet exist
if os.path.exists(HISTFILE):
    readline.read_history_file(HISTFILE)

def savehist():
    readline.write_history_file(HISTFILE)

atexit.register(savehist)

# Enable Color Prompts
######################

if os.environ.get( 'TERM' ) in [ 'xterm', 'xterm-color', 'xterm-256color', 'screen', 'screen-256color', 'screen-bce' ]:
    sys.ps1 = '%s>>> %s' % (GREEN, NORMAL)
    sys.ps2 = '%s... %s' % (RED, NORMAL)

# Welcome message
#################

print """%s
The Python shell is coming at 'ya, punk!
You've got color, history, and completion
(and vi-mode keybindings if your ~/.inputrc doesn't suck).
%sOh yeah, it is that cool.
%s""" % (RED, GREEN, NORMAL)
