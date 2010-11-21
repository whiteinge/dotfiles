# -*- coding: utf-8 -*-
#
# Copyright (c) 2009 by xt <xt@bash.no>
# Copyright (c) 2009 by penryu <penryu@gmail.com>
# Copyright (c) 2010 by Blake Winton <bwinton@latte.ca>
# Copyright (c) 2010 by Aron Griffis <agriffis@n01se.net>
# Copyright (c) 2010 by Jani Kesänen <jani.kesanen@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# (this script requires WeeChat 0.3.0 or newer)
#
# History:
# 2010-08-07, Filip H.F. "FiXato" Slagter <fixato@gmail.com>
#  version 0.8: add command on attach feature
# 2010-05-07, Jani Kesänen <jani.kesanen@gmail.com>
#  version 0.7: add command on detach feature
# 2010-03-07, Aron Griffis <agriffis@n01se.net>
#  version 0.6: move socket check to register,
#               add hook_config for interval,
#               reduce default interval from 60 to 5
# 2010-02-19, Blake Winton <bwinton@latte.ca>
#  version 0.5: add option to change nick when away
# 2010-01-18, xt
#  version 0.4: only update servers that are connected
# 2009-11-30, xt <xt@bash.no>
#  version 0.3: do not touch servers that are manually set away
# 2009-11-27, xt <xt@bash.no>
#  version 0.2: code for TMUX from penryu
# 2009-11-27, xt <xt@bash.no>
#  version 0.1: initial release

import weechat as w
import re
import os

SCRIPT_NAME    = "screen_away"
SCRIPT_AUTHOR  = "xt <xt@bash.no>"
SCRIPT_VERSION = "0.8"
SCRIPT_LICENSE = "GPL3"
SCRIPT_DESC    = "Set away status on screen detach"

settings = {
        'message': 'Detached from screen',
        'interval': '5',        # How often in seconds to check screen status
        'away_suffix': '',      # What to append to your nick when you're away.
        'command_on_attach': '', # Command to execute on attach
        'command_on_detach': '' # Command to execute on detach
}

TIMER = None
SOCK = None
AWAY = False

def set_timer():
    '''Update timer hook with new interval'''

    global TIMER
    if TIMER:
        w.unhook(TIMER);
    TIMER = w.hook_timer(int(w.config_get_plugin('interval')) * 1000,
            0, 0, "screen_away_timer_cb", '')

def screen_away_config_cb(data, option, value):
    if option.endswith(".interval"):
        set_timer()
    return w.WEECHAT_RC_OK

def get_servers():
    '''Get the servers that are not away, or were set away by this script'''

    infolist = w.infolist_get('irc_server','','')
    buffers = []
    while w.infolist_next(infolist):
        if not w.infolist_integer(infolist, 'is_connected') == 1:
            continue
        if not w.infolist_integer(infolist, 'is_away') or \
               w.infolist_string(infolist, 'away_message') == \
               w.config_get_plugin('message'):
            buffers.append((w.infolist_pointer(infolist, 'buffer'),
                w.infolist_string(infolist, 'nick')))
    w.infolist_free(infolist)
    return buffers

def screen_away_timer_cb(buffer, args):
    '''Check if screen is attached, update awayness'''

    global AWAY, SOCK

    suffix = w.config_get_plugin('away_suffix')
    attached = os.access(SOCK, os.X_OK) # X bit indicates attached

    if attached and AWAY:
        w.prnt('', '%s: Screen attached. Clearing away status' % SCRIPT_NAME)
        for server, nick in get_servers():
            w.command(server,  "/away")
            if suffix and nick.endswith(suffix):
                nick = nick[:-len(suffix)]
                w.command(server,  "/nick %s" % nick)
        AWAY = False
        if w.config_get_plugin("command_on_attach"):
            w.command("", w.config_get_plugin("command_on_attach"))

    elif not attached and not AWAY:
        w.prnt('', '%s: Screen detached. Setting away status' % SCRIPT_NAME)
        for server, nick in get_servers():
            if suffix:
                w.command(server, "/nick %s%s" % (nick, suffix));
            w.command(server, "/away %s" % w.config_get_plugin('message'));
        AWAY = True
        if w.config_get_plugin("command_on_detach"):
            w.command("", w.config_get_plugin("command_on_detach"))

    return w.WEECHAT_RC_OK


if w.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE,
                    SCRIPT_DESC, "", ""):
    for option, default_value in settings.iteritems():
        if not w.config_is_set_plugin(option):
            w.config_set_plugin(option, default_value)

    if 'STY' in os.environ.keys():
        # We are running under screen
        cmd_output = os.popen('env LC_ALL=C screen -ls').read()
        match = re.search(r'Sockets? in (/.+)\.', cmd_output)
        if match:
            SOCK = os.path.join(match.group(1), os.environ['STY'])

    if not SOCK and 'TMUX' in os.environ.keys():
        # We are running under tmux
        socket_data = os.environ['TMUX']
        SOCK = socket_data.rsplit(',',2)[0]

    if SOCK:
        set_timer()
        w.hook_config("plugins.var.python." + SCRIPT_NAME + ".*",
            "screen_away_config_cb", "")
