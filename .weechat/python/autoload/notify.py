# Author: lavaramano <lavaramano AT gmail DOT com>
# Improved by: BaSh - <bash.lnx AT gmail DOT com>
# Ported to Weechat 0.3.0 by: Sharn - <sharntehnub AT gmail DOT com)
# This Plugin Calls the libnotify bindings via python when somebody says your nickname, sends you a query, etc.
# To make it work, you may need to download: python-notify (and libnotify - libgtk)
# Requires Weechat 0.3.0
# Released under GNU GPL v2
#
# 2009-06-16, kba <unixprog@gmail.com.org>:
#     version 0.0.3: added config options for icon and urgency
# 2009-05-02, FlashCode <flashcode@flashtux.org>:
#     version 0.0.2.1: sync with last API changes

import weechat, pynotify, string

weechat.register("notify", "lavaramano", "0.0.3", "GPL", "notify: A real time notification system for weechat", "", "")

# script options
settings = {
    "show_hilights"             : "on",
    "show_priv_msg"             : "on",
    "icon"                      : "/usr/share/pixmaps/weechat.xpm",
    "urgency"                   : "normal",
}

# Init everything
for option, default_value in settings.items():
    if weechat.config_get_plugin(option) == "":
        weechat.config_set_plugin(option, default_value)

# Hook privmsg/hilights
weechat.hook_print("", "", "", 1, "nofify_show_hi", "")
weechat.hook_signal("weechat_pv", "nofify_show_priv", "")

# Functions
def nofify_show_hi( data, bufferp, uber_empty, tagsn, isdisplayed, ishilight, prefix, message ):
    """Sends highlighted message to be printed on notification"""
    if ishilight == "1" and weechat.config_get_plugin('show_hilights') == "on":
        if not weechat.buffer_get_string(bufferp, "short_name"):
            buffer = weechat.buffer_get_string(bufferp, "name")
        else:
            buffer = weechat.buffer_get_string(bufferp, "short_name")

        show_notification(buffer , "<b>"+prefix+"</b>: "+message)
        if weechat.config_get_plugin('debug') == "on":
            print prefix

    return weechat.WEECHAT_RC_OK

def nofify_show_priv( data, signal, message ):
    """Sends private message to be printed on notification"""
    if weechat.config_get_plugin('show_priv_msg') == "on":
        show_notification("Private message: ",  message)
    return weechat.WEECHAT_RC_OK

def show_notification(chan,message):
    pynotify.init("wee-notifier")

    # determine urgency level
    if weechat.config_get_plugin('urgency') == "low":
        urgency_level = pynotify.URGENCY_LOW
    elif weechat.config_get_plugin('urgency') == "critical":
        urgency_level = pynotify.URGENCY_CRITICAL
    else:
        urgency_level = pynotify.URGENCY_NORMAL

    wn = pynotify.Notification(chan, message, weechat.config_get_plugin('icon'))
    wn.set_urgency(urgency_level)
    #wn.set_timeout(pynotify.EXPIRES_NEVER)
    wn.show()

# vim: ai ts=4 sts=4 et sw=4
