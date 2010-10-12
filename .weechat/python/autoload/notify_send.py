# Author: lavaramano <lavaramano AT gmail DOT com>
# Improved by: BaSh - <bash.lnx AT gmail DOT com>
# Ported to Weechat 0.3.0 by: Sharn - <sharntehnub AT gmail DOT com)
# This Plugin Calls the libnotify bindings via python when somebody says your nickname, sends you a query, etc.
# To make it work, you may need to download: python-notify (and libnotify - libgtk)
# Requires Weechat 0.3.0
# Released under GNU GPL v2

import weechat, os

weechat.register("notify-send", "whiteinge", "0.0.1", "GPL", "notify-send: calls notify-send cli on highlight", "", "")

# script options
settings = {
    "show_hilights"      : "on",
    "show_priv_msg"      : "on",
    "nick_separator"     : ": ",
    "icon"               : "/usr/share/pixmaps/weechat.xpm",
    "urgency"            : "normal",
    "smart_notification" : "off",
}

# Init everything
for option, default_value in settings.items():
    if weechat.config_get_plugin(option) == "":
        weechat.config_set_plugin(option, default_value)

# Hook privmsg/hilights
weechat.hook_print("", "irc_privmsg", "", 1, "notify_show", "")

# Functions
def notify_show(data, bufferp, uber_empty, tagsn, isdisplayed,
        ishilight, prefix, message):
    """Sends highlighted message to be printed on notification"""

    if (weechat.config_get_plugin('smart_notification') == "on" and
            bufferp == weechat.current_buffer()):
        pass

    elif (weechat.buffer_get_string(bufferp, "localvar_type") == "private" and
            weechat.config_get_plugin('show_priv_msg') == "on"):
        show_notification(prefix, message)

    elif (ishilight == "1" and 
            weechat.config_get_plugin('show_hilights') == "on"):
        buffer = (weechat.buffer_get_string(bufferp, "short_name") or
                weechat.buffer_get_string(bufferp, "name"))
        show_notification(buffer, prefix +
                weechat.config_get_plugin('nick_separator') + message)

    return weechat.WEECHAT_RC_OK

def show_notification(chan,message):
    icon = weechat.config_get_plugin('icon')
    urgency = 'normal'
    os.system('notify-send -u %(urgency)s -i %(icon)s %(chan)s %(message)s' % locals())
