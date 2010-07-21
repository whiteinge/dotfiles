# -*- coding: utf-8 -*-
#
# Copyright (c) 2009-2010 by FlashCode <flashcode@flashtux.org>
# Copyright (c) 2010 by xt <xt@bash.no>
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
# Jabber/XMPP protocol for WeeChat.
# (this script requires WeeChat 0.3.0 (or newer) and xmpppy library)
#
# For help, see /help jabber
# Happy chat, enjoy :)
#
# History:
# 2010-06-09 iiijjjiii <iiijjjiii@gmail.com>
#     add connect server and port options (required for google talk)
#     add private option permitting messages to be displayed in separate
#       chat buffers or in a single server buffer
#     add jid aliases
#     add keepalive ping
# 2010-03-17, xt <xt@bash.no>:
#     add autoreconnect option, autoreconnects on protocol error
# 2010-03-17, xt <xt@bash.no>:
#     add autoconnect option, add new command /jmsg with -server option
# 2009-02-22, FlashCode <flashcode@flashtux.org>:
#     first version (unofficial)
#

SCRIPT_NAME    = "jabber"
SCRIPT_AUTHOR  = "FlashCode <flashcode@flashtux.org>"
SCRIPT_VERSION = "0.1-dev-20100609"
SCRIPT_LICENSE = "GPL3"
SCRIPT_DESC    = "Jabber/XMPP protocol for WeeChat"
SCRIPT_COMMAND = SCRIPT_NAME

import re
import warnings

import_ok = True

try:
    import weechat
except:
    print "This script must be run under WeeChat."
    print "Get WeeChat now at: http://www.weechat.org/"
    import_ok = False

# On import, xmpp may produce warnings about using hashlib instead of
# deprecated sha and md5. Since the code producing those warnings is
# outside this script, catch them and ignore.
original_filters = warnings.filters[:]
warnings.filterwarnings("ignore",category=DeprecationWarning)
try:
    import xmpp
except:
    print "Package python-xmpp (xmpppy) must be installed to use Jabber protocol."
    print "Get xmpppy with your package manager, or at this URL: http://xmpppy.sourceforge.net/"
    import_ok = False
finally:
    warnings.filters = original_filters

# ==============================[ global vars ]===============================

jabber_servers = []
jabber_server_options = {
    "jid"          : { "type"         : "string",
                       "desc"         : "jabber id (user@server.tld)",
                       "min"          : 0,
                       "max"          : 0,
                       "string_values": "",
                       "default"      : "",
                       "value"        : "",
                       "check_cb"     : "",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "password"     : { "type"         : "string",
                       "desc"         : "password for jabber id on server",
                       "min"          : 0,
                       "max"          : 0,
                       "string_values": "",
                       "default"      : "",
                       "value"        : "",
                       "check_cb"     : "",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "server"       : { "type"         : "string",
                       "desc"         : "connect server host or ip, eg. talk.google.com",
                       "min"          : 0,
                       "max"          : 0,
                       "string_values": "",
                       "default"      : "",
                       "value"        : "",
                       "check_cb"     : "",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "port"         : { "type"         : "integer",
                       "desc"         : "connect server port, eg. 5223",
                       "min"          : 0,
                       "max"          : 65535,
                       "string_values": "",
                       "default"      : "5222",
                       "value"        : "5222",
                       "check_cb"     : "",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "autoconnect"  : { "type"         : "boolean",
                       "desc"         : "automatically connect to server when script is starting",
                       "min"          : 0,
                       "max"          : 0,
                       "string_values": "",
                       "default"      : "off",
                       "value"        : "off",
                       "check_cb"     : "",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "autoreconnect": { "type"         : "boolean",
                       "desc"         : "automatically reconnect to server when disconnected",
                       "min"          : 0,
                       "max"          : 0,
                       "string_values": "",
                       "default"      : "off",
                       "value"        : "off",
                       "check_cb"     : "",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "private"      : { "type"         : "boolean",
                       "desc"         : "display messages in separate chat buffers instead of a single server buffer",
                       "min"          : 0,
                       "max"          : 0,
                       "string_values": "",
                       "default"      : "on",
                       "value"        : "on",
                       "check_cb"     : "",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "ping_interval": { "type"         : "integer",
                       "desc"         : "Number of seconds between server pings. 0 = disable",
                       "min"          : 0,
                       "max"          : 9999999,
                       "string_values": "",
                       "default"      : "0",
                       "value"        : "0",
                       "check_cb"     : "ping_interval_check_cb",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    "ping_timeout" : { "type"         : "integer",
                       "desc"         : "Number of seconds to allow ping to respond before timing out",
                       "min"          : 0,
                       "max"          : 9999999,
                       "string_values": "",
                       "default"      : "10",
                       "value"        : "10",
                       "check_cb"     : "ping_timeout_check_cb",
                       "change_cb"    : "",
                       "delete_cb"    : "",
                       },
    }
jabber_config_file = None
jabber_config_section = {}
jabber_config_option = {}
jabber_jid_aliases = {}             # { 'alias1': 'jid1', 'alias2': 'jid2', ... }

# =================================[ config ]=================================

def jabber_config_init():
    """ Initialize config file: create sections and options in memory. """
    global jabber_config_file, jabber_config_section
    jabber_config_file = weechat.config_new("jabber", "jabber_config_reload_cb", "")
    if not jabber_config_file:
        return
    # look
    jabber_config_section["look"] = weechat.config_new_section(
        jabber_config_file, "look", 0, 0, "", "", "", "", "", "", "", "", "", "")
    if not jabber_config_section["look"]:
        weechat.config_free(jabber_config_file)
        return
    jabber_config_option["debug"] = weechat.config_new_option(
        jabber_config_file, jabber_config_section["look"],
        "debug", "boolean", "display debug messages", "", 0, 0,
        "off", "off", 0, "", "", "", "", "", "")
    # color
    jabber_config_section["color"] = weechat.config_new_section(
        jabber_config_file, "color", 0, 0, "", "", "", "", "", "", "", "", "", "")
    if not jabber_config_section["color"]:
        weechat.config_free(jabber_config_file)
        return
    jabber_config_option["message_join"] = weechat.config_new_option(
        jabber_config_file, jabber_config_section["color"],
        "message_join", "color", "color for text in join messages", "", 0, 0,
        "green", "green", 0, "", "", "", "", "", "")
    jabber_config_option["message_quit"] = weechat.config_new_option(
        jabber_config_file, jabber_config_section["color"],
        "message_quit", "color", "color for text in quit messages", "", 0, 0,
        "red", "red", 0, "", "", "", "", "", "")
    # server
    jabber_config_section["server"] = weechat.config_new_section(
        jabber_config_file, "server", 0, 0,
        "jabber_config_server_read_cb", "", "jabber_config_server_write_cb", "",
        "", "", "", "", "", "")
    if not jabber_config_section["server"]:
        weechat.config_free(jabber_config_file)
        return
    jabber_config_section["jid_aliases"] = weechat.config_new_section(
        jabber_config_file, "jid_aliases", 0, 0,
        "jabber_config_jid_aliases_read_cb", "",
        "jabber_config_jid_aliases_write_cb", "",
        "", "", "", "", "", "")
    if not jabber_config_section["jid_aliases"]:
        weechat.config_free(jabber_config_file)
        return

def jabber_config_reload_cb(data, config_file):
    """ Reload config file. """
    return weechat.WEECHAT_CONFIG_READ_OK

def jabber_config_server_read_cb(data, config_file, section, option_name, value):
    """ Read server option in config file. """
    global jabber_servers
    rc = weechat.WEECHAT_CONFIG_OPTION_SET_ERROR
    items = option_name.split(".", 1)
    if len(items) == 2:
        server = jabber_search_server_by_name(items[0])
        if not server:
            server = Server(items[0])
            jabber_servers.append(server)
        if server:
            rc = weechat.config_option_set(server.options[items[1]], value, 1)
    return rc

def jabber_config_server_write_cb(data, config_file, section_name):
    """ Write server section in config file. """
    global jabber_servers
    weechat.config_write_line(config_file, section_name, "")
    for server in jabber_servers:
        for name, option in sorted(server.options.iteritems()):
            weechat.config_write_option(config_file, option)
    return weechat.WEECHAT_RC_OK

def jabber_config_jid_aliases_read_cb(data, config_file, section, option_name, value):
    """ Read jid_aliases option in config file. """
    global jabber_jid_aliases
    jabber_jid_aliases[option_name] = value
    option = weechat.config_new_option(
        config_file, section,
        option_name, "string", "jid alias", "", 0, 0,
        "", value, 0, "", "", "", "", "", "")
    if not option:
        return weechat.WEECHAT_CONFIG_OPTION_SET_ERROR
    return weechat.WEECHAT_CONFIG_OPTION_SET_OK_CHANGED

def jabber_config_jid_aliases_write_cb(data, config_file, section_name):
    """ Write jid_aliases section in config file. """
    global jabber_jid_aliases
    weechat.config_write_line(config_file, section_name, "")
    for alias, jid in sorted(jabber_jid_aliases.iteritems()):
        weechat.config_write_line(config_file, alias, jid)
    return weechat.WEECHAT_RC_OK

def jabber_config_read():
    """ Read jabber config file (jabber.conf). """
    global jabber_config_file
    return weechat.config_read(jabber_config_file)

def jabber_config_write():
    """ Write jabber config file (jabber.conf). """
    global jabber_config_file
    return weechat.config_write(jabber_config_file)

def jabber_debug_enabled():
    """ Return True if debug is enabled. """
    global jabber_config_options
    if weechat.config_boolean(jabber_config_option["debug"]):
        return True
    return False

def jabber_config_color(color):
    """ Return color code for a jabber color option. """
    global jabber_config_option
    if color in jabber_config_option:
        return weechat.color(weechat.config_color(jabber_config_option[color]))
    return ""

def ping_timeout_check_cb(server_name, option, value):
    global jabber_config_file, jabber_config_section
    ping_interval_option = weechat.config_search_option(
        jabber_config_file,
        jabber_config_section["server"],
        "%s.ping_interval" % (server_name)
        )
    ping_interval = weechat.config_integer(ping_interval_option)
    if int(ping_interval) and int(value) >= int(ping_interval):
        weechat.prnt("", "\njabber: unable to update 'ping_timeout' for server %s" % (server_name))
        weechat.prnt("", "jabber: to prevent multiple concurrent pings, ping_interval must be greater than ping_timeout")
        return weechat.WEECHAT_CONFIG_OPTION_SET_ERROR
    return weechat.WEECHAT_CONFIG_OPTION_SET_OK_CHANGED

def ping_interval_check_cb(server_name, option, value):
    global jabber_config_file, jabber_config_section
    ping_timeout_option = weechat.config_search_option(
        jabber_config_file,
        jabber_config_section["server"],
        "%s.ping_timeout" % (server_name)
        )
    ping_timeout = weechat.config_integer(ping_timeout_option)
    if int(value) and int(ping_timeout) >= int(value):
        weechat.prnt("", "\njabber: unable to update 'ping_interval' for server %s" % (server_name))
        weechat.prnt("", "jabber: to prevent multiple concurrent pings, ping_interval must be greater than ping_timeout")
        return weechat.WEECHAT_CONFIG_OPTION_SET_ERROR
    return weechat.WEECHAT_CONFIG_OPTION_SET_OK_CHANGED

# ================================[ servers ]=================================

class Server:
    """ Class to manage a server: buffer, connection, send/recv data. """

    def __init__(self, name, **kwargs):
        """ Init server """
        global jabber_config_file, jabber_config_section, jabber_server_options
        self.name = name
        # create options (user can set them with /set)
        self.options = {}
        # if the value is provided, use it, otherwise use the default
        values = {}
        for option_name, props in jabber_server_options.iteritems():
            values[option_name] = props["default"]
        values['name'] = name
        values.update(**kwargs)
        for option_name, props in jabber_server_options.iteritems():
            self.options[option_name] = weechat.config_new_option(
                jabber_config_file, jabber_config_section["server"],
                self.name + "." + option_name, props["type"], props["desc"],
                props["string_values"], props["min"], props["max"],
                props["default"], values[option_name], 0,
                props["check_cb"], self.name, props["change_cb"], "",
                props["delete_cb"], "")
        # internal data
        self.jid = None
        self.client = None
        self.sock = None
        self.hook_fd = None
        self.buffer = ""
        self.nick = ""
        self.chats = []
        self.buddies = []
        self.buddy = None
        self.ping_timer = None              # weechat.hook_timer for sending pings
        self.ping_timeout_timer = None      # weechat.hook_timer for monitoring ping timeout
        self.ping_up = False                # Connection status as per pings.

    def option_string(self, option_name):
        """ Return a server option, as string. """
        return weechat.config_string(self.options[option_name])

    def option_boolean(self, option_name):
        """ Return a server option, as boolean. """
        return weechat.config_boolean(self.options[option_name])

    def option_integer(self, option_name):
        """ Return a server option, as string. """
        return weechat.config_integer(self.options[option_name])

    def connect(self):
        """ Connect to Jabber server. """
        if not self.buffer:
            bufname = "%s.server.%s" % (SCRIPT_NAME, self.name)
            self.buffer = weechat.buffer_search("python", bufname)
            if not self.buffer:
                self.buffer = weechat.buffer_new(bufname,
                                                 "jabber_buffer_input_cb", "",
                                                 "jabber_buffer_close_cb", "")
            if self.buffer:
                weechat.buffer_set(self.buffer, "short_name", self.name)
                weechat.buffer_set(self.buffer, "localvar_set_type", "server")
                weechat.buffer_set(self.buffer, "localvar_set_server", self.name)
                weechat.buffer_set(self.buffer, "nicklist", "1")
                weechat.buffer_set(self.buffer, "nicklist_display_groups", "1")
                weechat.buffer_set(self.buffer, "display", "auto")
        self.disconnect()
        self.buddy = Buddy(jid=self.option_string("jid"), server=self)
        server = self.option_string("server")
        port = self.option_integer("port")
        self.client = xmpp.Client(server=self.buddy.domain, debug=[])
        conn = None
        server_tuple = None
        if server:
            if port:
                server_tuple = (server, port)
            else:
                server_tuple = (server)

        # self.client.connect() may produce a "socket.ssl() is deprecated"
        # warning. Since the code producing the warning is outside this script,
        # catch it and ignore.
        original_filters = warnings.filters[:]
        warnings.filterwarnings("ignore",category=DeprecationWarning)
        try:
            conn = self.client.connect(server=server_tuple)
        finally:
            warnings.filters = original_filters

        if conn:
            weechat.prnt(self.buffer, "jabber: connection ok with %s" % conn)
            res = self.buddy.resource
            if not res:
                res = "WeeChat"
            auth = self.client.auth(self.buddy.username,
                                    self.option_string("password"),
                                    res)
            if auth:
                weechat.prnt(self.buffer, "jabber: authentication ok (using %s)" % auth)
                self.client.RegisterHandler("presence", self.presence_handler)
                self.client.RegisterHandler("iq", self.iq_handler)
                self.client.RegisterHandler("message", self.message_handler)
                self.client.sendInitPresence(requestRoster=0)
                #client.SendInitPresence(requestRoster=0)
                self.sock = self.client.Connection._sock.fileno()
                self.hook_fd = weechat.hook_fd(self.sock, 1, 0, 0, "jabber_fd_cb", "")
                weechat.buffer_set(self.buffer, "highlight_words", self.buddy.username)
                weechat.buffer_set(self.buffer, "localvar_set_nick", self.buddy.username);
                hook_away = weechat.hook_command_run("/away -all*", "jabber_away_command_run_cb", "")
                self.ping_up = True
            else:
                weechat.prnt(self.buffer, "%sjabber: could not authenticate"
                             % weechat.prefix("error"))
                self.ping_up = False
                self.client = None
        else:
            weechat.prnt(self.buffer, "%sjabber: could not connect"
                         % weechat.prefix("error"))
            self.ping_up = False
            self.client = None
        return self.is_connected()

    def is_connected(self):
        """Return connect status"""
        if not self.client or not self.client.isConnected():
            return False
        else:
            return True

    def add_chat(self, buddy):
        """Create a chat buffer for a buddy"""
        chat = Chat(self, buddy, switch_to_buffer=False)
        self.chats.append(chat)
        return chat

    def print_debug_server(self, message):
        """ Print debug message on server buffer. """
        if jabber_debug_enabled():
            weechat.prnt(self.buffer, "%sjabber: %s" % (weechat.prefix("network"), message))

    def print_debug_handler(self, handler_name, node):
        """ Print debug message for a handler on server buffer. """
        self.print_debug_server("%s_handler, xml message:\n%s"
                                % (handler_name,
                                   node.__str__(fancy=True).encode("utf-8")))

    def print_error(self, message):
        """ Print error message on server buffer. """
        if jabber_debug_enabled():
            weechat.prnt(self.buffer, "%sjabber: %s" % (weechat.prefix("error"), message))

    def presence_handler(self, conn, node):
        self.print_debug_handler("presence", node)
        buddy = self.search_buddy_list(node.getFrom().getStripped().encode("utf-8"), by='jid')
        if not buddy:
            buddy = self.add_buddy(jid=node.getFrom())
        action='update'
        node_type = node.getType()
        if node_type in ["error", "unavailable"]:
            action='remove'
        if action == 'update':
            away = node.getShow() in ["away", "xa"]
            status = ''
            if node.getStatus():
                status = node.getStatus().encode("utf-8")
            buddy.set_status(status=status, away=away)
        self.update_nicklist(buddy=buddy, action=action)
        return

    def iq_handler(self, conn, node):
        """ Receive iq message. """
        self.print_debug_handler("iq", node)
        #weechat.prnt(self.buffer, "jabber: iq handler")
        if node.getFrom() == self.buddy.domain:
            # type='result' => pong from server
            # type='error'  => error message from server
            # The ping_up is set True on an error message to handle cases where
            # the ping feature is not implemented on a server. It's a bit of a
            # hack, but if we can receive an error from the server, we assume
            # the connection to the server is up.
            if node.getType() in ['result', 'error']:
                self.delete_ping_timeout_timer()    # Disable the timeout feature
                self.ping_up = True
                if not self.client.isConnected() and weechat.config_boolean(self.options['autoreconnect']):
                    self.connect()

    def message_handler(self, conn, node):
        """ Receive message. """
        self.print_debug_handler("message", node)
        node_type = node.getType()
        if node_type not in ["message", "chat", None]:
            self.print_error("unknown message type: '%s'" % node_type)
            return
        jid = node.getFrom()
        body = node.getBody()
        if not jid or not body:
            return
        buddy = self.search_buddy_list(jid, by='jid')
        if not buddy:
            buddy = self.add_buddy(jid=jid)
        # If a chat buffer exists for the buddy, receive the message with that
        # buffer even if private is off. The buffer may have been created with
        # /jchat.
        recv_object = self
        if not buddy.chat and weechat.config_boolean(self.options['private']):
            self.add_chat(buddy)
        if buddy.chat:
            recv_object = buddy.chat
        recv_object.recv_message(buddy, body.encode("utf-8"))

    def recv(self):
        """ Receive something from Jabber server. """
        if not self.client:
            return
        try:
            self.client.Process(1)
        except xmpp.protocol.StreamError, e:
            weechat.prnt('', '%s: Error from server: %s' %(SCRIPT_NAME, e))
            self.disconnect()
            if weechat.config_boolean(self.options['autoreconnect']):
                autoreconnect_delay = 30
                weechat.command('', '/wait %s /%s connect %s' %(\
                    autoreconnect_delay, SCRIPT_COMMAND, self.name))

    def recv_message(self, buddy, message):
        """ Receive a message from buddy. """
        weechat.prnt_date_tags(self.buffer, 0, "notify_private",
                               "%s%s\t%s" % (weechat.color("chat_nick_other"),
                                             buddy.alias,
                                             message))

    def print_status(self, nickname, status):
        ''' Print a status in server window and in chat '''
        weechat.prnt(self.buffer, "%s%s has status %s" % (\
                weechat.prefix("action"),
                nickname,
                status))
        for chat in self.chats:
            if nickname in chat.buddy.alias:
                chat.print_status(status)
                break

    def send_message(self, buddy, message):
        """ Send a message to buddy.

        The buddy argument can be either a jid string,
        eg username@domain.tld/resource or a Buddy object instance.
        """
        recipient = buddy
        if isinstance(buddy, Buddy):
            recipient = buddy.jid
        if not self.ping_up:
            weechat.prnt(self.buffer, "%sjabber: unable to send message, connection is down"
                         % weechat.prefix("error"))
            return
        if self.client:
            msg = xmpp.protocol.Message(to=recipient, body=message, typ='chat')
            self.client.send(msg)

    def send_message_from_input(self, input=''):
        """ Send a message from input text on server buffer. """
        # Input must be of format "name: message" where name is a jid, bare_jid
        # or alias. The colon can be replaced with a comma as well.
        # Split input into name and message.
        if not re.compile(r'.+[:,].+').match(input):
            weechat.prnt(self.buffer, "%sjabber: %s" % (weechat.prefix("network"),
                "Invalid send format. Use  jid: message"
                ))
            return
        name, message = re.split('[:,]', input, maxsplit=1)
        buddy = self.search_buddy_list(name, by='alias')
        if not buddy:
            weechat.prnt(self.buffer,
                    "%sjabber: Invalid jid: %s" % (weechat.prefix("network"),
                    name))
            return
        # Send activity indicates user is no longer away, set it so
        if self.buddy and self.buddy.away:
            self.set_away('')
        self.send_message(buddy=buddy, message=message)
        try:
            sender = self.buddy.alias
        except:
            sender = self.jid
        weechat.prnt(self.buffer, "%s%s\t%s" % (weechat.color("chat_nick_self"),
                                               sender,
                                               message.strip()))

    def set_away(self, message):
        """ Set/unset away on server.

        If a message is provided, status is set to 'away'.
        If no message, then status is set to 'online'.
        """
        if message:
            show = 'xa'
            status = message
            self.buddy.set_status(away=True, status=message)
        else:
            show = None
            status = None
            self.buddy.set_status(away=False)
        for buddy in self.buddies:
            if buddy.jid == self.buddy.jid:
                continue
            pres = xmpp.protocol.Presence(to=buddy.jid, show=show, status=status)
            id = self.client.send(pres)

    def add_buddy(self, jid=None):
        buddy = Buddy(jid=jid, server=self)
        self.buddies.append(buddy)
        return buddy

    def display_buddies(self):
        """ Display buddies. """
        weechat.prnt(self.buffer, "")
        weechat.prnt(self.buffer, "Buddies:")

        len_max = { 'alias': 5, 'jid': 5 }
        lines = []
        for buddy in sorted(self.buddies, key=lambda x: str(x.jid)):
            alias = ''
            if buddy.alias != buddy.bare_jid:
                alias = buddy.alias
            lines.append( {
                'jid': str(buddy.jid),
                'alias': alias,
                'status': buddy.away_string(),
                })
            if len(alias) > len_max['alias']:
                len_max['alias'] = len(alias)
            if len(str(buddy.jid)) > len_max['jid']:
                len_max['jid'] = len(str(buddy.jid))
        prnt_format = "  %s%-" + str(len_max['jid']) + "s %-" + str(len_max['alias']) + "s %s"
        weechat.prnt(self.buffer, prnt_format % ('', 'JID', 'Alias', 'Status'))
        for line in lines:
            weechat.prnt(self.buffer, prnt_format % (weechat.color("chat_nick"),
                                                    line['jid'],
                                                    line['alias'],
                                                    line['status'],
                                                    ))

    def search_buddy_list(self, name, by='jid'):
        """ Search for a buddy by name.

        Args:
            name: string, the buddy name to search, eg the jid or alias
            by: string, either 'alias' or 'jid', determines which Buddy
                property to match on, default 'jid'

        Notes:
            If the 'by' parameter is set to 'jid', the search matches on all
            Buddy object jid properties, followed by all bare_jid properties.
            Once a match is found it is returned.

            If the 'by' parameter is set to 'alias', the search matches on all
            Buddy object alias properties.

            Generally, set the 'by' parameter to 'jid' when the jid is provided
            from a server, for example from a received message. Set 'by' to
            'alias' when the jid is provided by the user.
        """
        if by == 'jid':
            for buddy in self.buddies:
                if str(buddy.jid) == name:
                    return buddy
            for buddy in self.buddies:
                if buddy.bare_jid == name:
                    return buddy
        else:
            for buddy in self.buddies:
                if buddy.alias == name:
                    return buddy
        return None

    def update_nicklist(self, buddy=None, action=None):
        """Update buddy in nicklist
            Args:
                buddy: Buddy object instance
                action: string, one of 'update' or 'remove'
        """
        if not buddy:
            return
        if not action in ['remove', 'update']:
            return
        ptr_nick_gui = weechat.nicklist_search_nick(self.buffer, "", buddy.alias)
        weechat.nicklist_remove_nick(self.buffer, ptr_nick_gui)
        msg = ''
        prefix = ''
        color = ''
        away = ''
        if action == 'update':
            nick_color = "bar_fg"
            if buddy.away:
                nick_color = "weechat.color.nicklist_away"
            weechat.nicklist_add_nick(self.buffer, "", buddy.alias,
                                      nick_color, "", "", 1)
            if not ptr_nick_gui:
                msg = 'joined'
                prefix = 'join'
                color = 'message_join'
                away = buddy.away_string()
        if action == 'remove':
            msg = 'quit'
            prefix = 'quit'
            color = 'message_quit'
        if msg:
            weechat.prnt(self.buffer, "%s%s%s%s has %s %s"
                         % (weechat.prefix(prefix),
                            weechat.color("chat_nick"),
                            buddy.alias,
                            jabber_config_color(color),
                            msg,
                            away))
        return

    def add_ping_timer(self):
        if self.ping_timer:
            self.delete_ping_timer()
        if not self.option_integer('ping_interval'):
            return
        self.ping_timer = weechat.hook_timer( self.option_integer('ping_interval') * 1000,
                0, 0, "jabber_ping_timer", self.name)
        return

    def delete_ping_timer(self):
        if self.ping_timer:
            weechat.unhook(self.ping_timer)
        self.ping_time = None
        return

    def add_ping_timeout_timer(self):
        if self.ping_timeout_timer:
            self.delete_ping_timeout_timer()
        if not self.option_integer('ping_timeout'):
            return
        self.ping_timeout_timer = weechat.hook_timer(
                self.option_integer('ping_timeout') * 1000, 0, 1,
                "jabber_ping_timeout_timer", self.name)
        return

    def delete_ping_timeout_timer(self):
        if self.ping_timeout_timer:
            weechat.unhook(self.ping_timeout_timer)
        self.ping_timeout_timer = None
        return

    def ping(self):
        if not self.is_connected():
            if not self.connect():
                return
        ping_node = xmpp.protocol.Protocol(name='ping', xmlns='urn:xmpp:ping')
        iq = xmpp.protocol.Iq(to=self.buddy.domain, payload=[ping_node], typ='get')
        id = self.client.send(iq)
        self.add_ping_timeout_timer()
        return

    def ping_time_out(self):
        self.delete_ping_timeout_timer()
        self.ping_up = False
        # A ping timeout indicates a server connection problem. Disconnect
        # completely.
        try:
            self.client.disconnected()
        except IOError:
            # An IOError is raised by the default DisconnectHandler
            pass
        self.disconnect()
        return

    def disconnect(self):
        """ Disconnect from Jabber server. """
        if self.hook_fd != None:
            weechat.unhook(self.hook_fd)
            self.hook_fd = None
        if self.client != None:
            if self.client.isConnected():
                self.client.disconnect()
            self.client = None
            self.jid = None
            self.sock = None
            self.buddy = None
            weechat.nicklist_remove_all(self.buffer)

    def close_buffer(self):
        """ Close server buffer. """
        if self.buffer != "":
            weechat.buffer_close(self.buffer)
            self.buffer = ""

    def delete(self):
        """ Delete server. """
        for chat in self.chats:
            chat.delete()
        self.delete_ping_timer()
        self.delete_ping_timeout_timer()
        self.disconnect()
        self.close_buffer()
        for option in self.options.keys():
            weechat.config_option_free(option)

def jabber_search_server_by_name(name):
    """ Search a server by name. """
    global jabber_servers
    for server in jabber_servers:
        if server.name == name:
            return server
    return None

def jabber_search_context(buffer):
    """ Search a server / chat for a buffer. """
    global jabber_servers
    context = { "server": None, "chat": None }
    for server in jabber_servers:
        if server.buffer == buffer:
            context["server"] = server
            return context
        for chat in server.chats:
            if chat.buffer == buffer:
                context["server"] = server
                context["chat"] = chat
                return context
    return context

def jabber_search_context_by_name(server_name):
    ''' Search for buffer given name of server '''

    bufname = "%s.server.%s" % (SCRIPT_NAME, server_name)
    return jabber_search_context(weechat.buffer_search("python", bufname))


# =================================[ chats ]==================================

class Chat:
    """ Class to manage private chat with buddy or MUC. """

    def __init__(self, server, buddy, switch_to_buffer):
        """ Init chat """
        self.server = server
        self.buddy = buddy
        buddy.chat = self
        bufname = "%s.%s.%s" % (SCRIPT_NAME, server.name, self.buddy.alias)
        self.buffer = weechat.buffer_new(bufname,
                                         "jabber_buffer_input_cb", "",
                                         "jabber_buffer_close_cb", "")
        self.buffer_title = self.buddy.alias
        if self.buffer:
            weechat.buffer_set(self.buffer, "title", self.buffer_title)
            weechat.buffer_set(self.buffer, "short_name", self.buddy.alias)
            weechat.buffer_set(self.buffer, "localvar_set_type", "private")
            weechat.buffer_set(self.buffer, "localvar_set_server", server.name)
            weechat.buffer_set(self.buffer, "localvar_set_channel", self.buddy.alias)
            weechat.hook_signal_send("logger_backlog",
                                     weechat.WEECHAT_HOOK_SIGNAL_POINTER, self.buffer)
            if switch_to_buffer:
                weechat.buffer_set(self.buffer, "display", "auto")

    def recv_message(self, buddy, message):
        """ Receive a message from buddy. """
        if buddy.alias != self.buffer_title:
            self.buffer_title = buddy.alias
            weechat.buffer_set(self.buffer, "title", "%s" % self.buffer_title)
        weechat.prnt_date_tags(self.buffer, 0, "notify_private",
                               "%s%s\t%s" % (weechat.color("chat_nick_other"),
                                             buddy.alias,
                                             message))

    def send_message(self, message):
        """ Send message to buddy. """
        if not self.server.ping_up:
            weechat.prnt(self.buffer, "%sjabber: unable to send message, connection is down"
                         % weechat.prefix("error"))
            return
        self.server.send_message(self.buddy, message)
        weechat.prnt(self.buffer, "%s%s\t%s" % (weechat.color("chat_nick_self"),
                                                   self.server.buddy.alias,
                                                   message))
    def print_status(self, status):
        ''' Print a status message in chat '''
        weechat.prnt(self.buffer, "%s%s has status %s" % (\
                    weechat.prefix("action"),
                    self.buddy.alias,
                    status))

    def close_buffer(self):
        """ Close chat buffer. """
        if self.buffer != "":
            weechat.buffer_close(self.buffer)
            self.buffer = ""

    def delete(self):
        """ Delete chat. """
        self.close_buffer()

# =================================[ buddies ]==================================

class Buddy:
    """ Class to manage buddies. """
    def __init__(self, jid=None, chat=None, server=None ):
        """ Init buddy

        Args:
            jid: xmpp.protocol.JID object instance or string
            chat: Chat object instance
            server: Server object instance

        The jid argument can be provided either as a xmpp.protocol.JID object
        instance or as a string, eg "username@domain.tld/resource". If a string
        is provided, it is converted and stored as a xmpp.protocol.JID object
        instance.
        """

        # The jid argument of xmpp.protocol.JID can be either a string or a
        # xmpp.protocol.JID object instance itself.
        self.jid = xmpp.protocol.JID(jid=jid)
        self.chat = chat
        self.server = server
        self.bare_jid = ''
        self.username = ''
        self.domain = ''
        self.resource = ''
        self.alias = ''
        self.away = True
        self.status = ''

        self.parse_jid()
        self.set_alias()
        return

    def away_string(self):
        """ Return a string with away and status, with color codes. """
        if not self:
            return ''
        if not self.away:
            return ''
        str_colon = ": "
        if not self.status:
            str_colon = ""
        return "%s(%saway%s%s%s)" % (weechat.color("chat_delimiters"),
                                      weechat.color("chat"),
                                      str_colon,
                                      self.status.replace("\n", " "),
                                      weechat.color("chat_delimiters"))

    def parse_jid(self):
        """Parse the jid property.

        The table shows how the jid is parsed and which properties are updated.

            Property        Value
            jid             myuser@mydomain.tld/myresource

            bare_jid        myuser@mydomain.tld
            username        myuser
            domain          mydomain.tld
            resource        myresource
        """
        if not self.jid:
            return
        self.bare_jid = self.jid.getStripped()
        self.username = self.jid.getNode()
        self.domain = self.jid.getDomain()
        self.resource = self.jid.getResource()
        return

    def set_alias(self):
        """Set the buddy alias.

        If an alias is defined in jabber_jid_aliases, it is used. Otherwise the
        alias is set to self.bare_jid.
        """
        if not self.bare_jid:
            self.alias = ''
        global jabber_jid_aliases
        self.alias = self.bare_jid
        for alias, jid in jabber_jid_aliases.iteritems():
            if jid == self.bare_jid:
                self.alias = alias
                break
        return

    def set_status(self, away=True, status=''):
        """Set the buddy status.

        Two properties define the buddy status.
            away - boolean, indicates whether the buddy is away or not.
            status - string, a message indicating the away status, eg 'in a meeting'
                   Comparable to xmpp presence <status/> element.
        """
        if not away and not status:
            status = 'online'
        # If the status has changed print a message on the server buffer
        if self.away != away or self.status != status:
            self.server.print_status(self.alias, status)
        self.away = away
        self.status = status
        return

# ================================[ commands ]================================

def jabber_hook_commands_and_completions():
    """ Hook commands and completions. """
    weechat.hook_command(SCRIPT_COMMAND, "List, add, remove, connect to Jabber servers",
                         "[ list | add name jid password [server[:port]] | connect server | "
                         "disconnect | del server | alias [add|del] | away [message] | buddies | "
                         "debug | set server setting [value] ]",
                         "      list: list servers and chats\n"
                         "       add: add a server"
                         "   connect: connect to server using password\n"
                         "disconnect: disconnect from server\n"
                         "       del: delete server\n"
                         "     alias: manage jid aliases\n"
                         "      away: set away with a message (if no message, away is unset)\n"
                         "   buddies: display buddies on server\n"
                         "     debug: toggle jabber debug on/off (for all servers)\n"
                         "\n"
                         "Without argument, this command lists servers and chats.\n"
                         "\n"
                         "Examples:\n"
                         "  Add a server:       /jabber add myserver user@server.tld password\n"
                         "  Add gtalk server:   /jabber add myserver user@gmail.com password talk.google.com:5223\n"
                         "  Connect to server:  /jabber connect myserver\n"
                         "  Disconnect:         /jabber disconnect myserver\n"
                         "  Delete server:      /jabber del myserver\n"
                         "\n"
                         "Aliases:\n"
                         "  List aliases:    /jabber alias \n"
                         "  Add an alias:    /jabber alias add alias_name jid\n"
                         "  Delete an alias: /jabber alias del alias_name\n"
                         "\n"
                         "Other jabber commands:\n"
                         "  /jchat  chat with a buddy (in private buffer)\n"
                         "  /jmsg   send message to a buddy",
                         "list %(jabber_servers)"
                         " || add %(jabber_servers)"
                         " || connect %(jabber_servers)"
                         " || disconnect %(jabber_servers)"
                         " || del %(jabber_servers)"
                         " || alias add|del %(jabber_jid_aliases)"
                         " || away"
                         " || buddies"
                         " || debug",
                         "jabber_cmd_jabber", "")
    weechat.hook_command("jchat", "Chat with a Jabber buddy",
                         "buddy",
                         "buddy: buddy id",
                         "",
                         "jabber_cmd_jchat", "")
    weechat.hook_command("jmsg", "Send a messge to a buddy",
                         "[-server servername] buddy text",
                         "servername: name of jabber server buddy is on\n"
                         "     buddy: buddy id",
                         "",
                         "jabber_cmd_jmsg", "")
    weechat.hook_completion("jabber_servers", "list of jabber servers",
                            "jabber_completion_servers", "")
    weechat.hook_completion("jabber_jid_aliases", "list of jabber jid aliases",
                            "jabber_completion_jid_aliases", "")

def jabber_list_servers_chats(name):
    """ List servers and chats. """
    global jabber_servers
    weechat.prnt("", "")
    if len(jabber_servers) > 0:
        weechat.prnt("", "jabber servers:")
        for server in jabber_servers:
            if name == "" or server.name.find(name) >= 0:
                conn_server = ''
                if server.option_string("server"):
                    conn_server = ':'.join(
                            (server.option_string("server"),
                            server.option_string("port")))
                connected = ""
                if server.sock >= 0:
                    connected = "(connected)"
                weechat.prnt("", "  %s - %s %s %s" % (server.name,
                    server.option_string("jid"), conn_server, connected))
                for chat in server.chats:
                    weechat.prnt("", "    chat with %s" % (chat.buddy))
    else:
        weechat.prnt("", "jabber: no server defined")

def jabber_cmd_jabber(data, buffer, args):
    """ Command '/jabber'. """
    global jabber_servers, jabber_config_option
    if args == "" or args == "list":
        jabber_list_servers_chats("")
    else:
        argv = args.split(" ")
        argv1eol = ""
        pos = args.find(" ")
        if pos > 0:
            argv1eol = args[pos+1:]
        if argv[0] == "list":
            jabber_list_servers_chats(argv[1])
        elif argv[0] == "add":
            if len(argv) >= 4:
                server = jabber_search_server_by_name(argv[1])
                if server:
                    weechat.prnt("", "jabber: server '%s' already exists" % argv[1])
                else:
                    kwargs = {'jid': argv[2], 'password': argv[3]}
                    if len(argv) > 4:
                        conn_server, _, conn_port = argv[4].partition(':')
                        if conn_port and not conn_port.isdigit():
                            weechat.prnt("", "jabber: error, invalid port, digits only")
                            return weechat.WEECHAT_RC_OK
                        if conn_server: kwargs['server'] = conn_server
                        if conn_port: kwargs['port'] = conn_port
                    server = Server(argv[1], **kwargs)
                    jabber_servers.append(server)
                    weechat.prnt("", "jabber: server '%s' created" % argv[1])
            else:
                weechat.prnt("", "jabber: unable to add server, missing arguments")
                weechat.prnt("", "jabber: usage: /jabber add name jid password [server[:port]]")
        elif argv[0] == "alias":
            alias_command = AliasCommand(buffer, argv=argv[1:])
            alias_command.run()
        elif argv[0] == "connect":
            server = None
            if len(argv) >= 2:
                server = jabber_search_server_by_name(argv[1])
                if not server:
                    weechat.prnt("", "jabber: server '%s' not found" % argv[1])
            else:
                context = jabber_search_context(buffer)
                if context["server"]:
                    server = context["server"]
            if server:
                if weechat.config_boolean(server.options['autoreconnect']):
                    server.ping()               # This will connect and update ping status
                    server.add_ping_timer()
                else:
                    server.connect()
        elif argv[0] == "disconnect":
            server = None
            if len(argv) >= 2:
                server = jabber_search_server_by_name(argv[1])
                if not server:
                    weechat.prnt("", "jabber: server '%s' not found" % argv[1])
            else:
                context = jabber_search_context(buffer)
                if context["server"]:
                    server = context["server"]
            context = jabber_search_context(buffer)
            if server:
                server.delete_ping_timer()
                server.disconnect()
        elif argv[0] == "del":
            if len(argv) >= 2:
                server = jabber_search_server_by_name(argv[1])
                if server:
                    server.delete()
                    jabber_servers.remove(server)
                    weechat.prnt("", "jabber: server '%s' deleted" % argv[1])
                else:
                    weechat.prnt("", "jabber: server '%s' not found" % argv[1])
        elif argv[0] == "send":
            if len(argv) >= 3:
                context = jabber_search_context(buffer)
                if context["server"]:
                    buddy = context['server'].search_buddy_list(argv[1], by='alias')
                    message = ' '.join(argv[2:])
                    context["server"].send_message(buddy, message)
        elif argv[0] == "read":
            jabber_config_read()
        elif argv[0] == "away":
            context = jabber_search_context(buffer)
            if context["server"]:
                context["server"].set_away(argv1eol)
        elif argv[0] == "buddies":
            context = jabber_search_context(buffer)
            if context["server"]:
                context["server"].display_buddies()
        elif argv[0] == "debug":
            weechat.config_option_set(jabber_config_option["debug"], "toggle", 1)
            if jabber_debug_enabled():
                weechat.prnt("", "jabber: debug is now ON")
            else:
                weechat.prnt("", "jabber: debug is now off")
        else:
            weechat.prnt("", "jabber: unknown action")
    return weechat.WEECHAT_RC_OK

def jabber_cmd_jchat(data, buffer, args):
    """ Command '/jchat'. """
    if args:
        context = jabber_search_context(buffer)
        if context["server"]:
            buddy = context["server"].search_buddy_list(args, by='alias')
            if not buddy:
                buddy = context["server"].add_buddy(jid=args)
            if not buddy.chat:
                context["server"].add_chat(buddy)
            weechat.buffer_set(buddy.chat.buffer, "display", "auto")
    return weechat.WEECHAT_RC_OK

def jabber_cmd_jmsg(data, buffer, args):
    """ Command '/jmsg'. """
    if args:
        argv = args.split()
        if len(argv) < 2:
            return weechat.WEECHAT_RC_OK
        if argv[0] == '-server':
            context = jabber_search_context_by_name(argv[1])
            recipient = argv[2]
            message = " ".join(argv[3:])
        else:
            context = jabber_search_context(buffer)
            recipient = argv[0]
            message = " ".join(argv[1:])
        if context["server"]:
            buddy = context['server'].search_buddy_list(recipient, by='alias')
            context["server"].send_message(buddy, message)

    return weechat.WEECHAT_RC_OK

def jabber_away_command_run_cb(data, buffer, command):
    """ Callback called when /away -all command is run """
    global jabber_servers
    words = command.split(None, 2)
    if len(words) < 2:
        return
    message = ''
    if len(words) > 2:
        message = words[2]
    for server in jabber_servers:
        server.set_away(message)
    return weechat.WEECHAT_RC_OK


class AliasCommand(object):
    """Class representing a jabber alias command, ie /jabber alias ..."""

    def __init__(self, buffer, argv=None):
        """
        Args:
            bufffer: the weechat buffer the command was run in
            argv: list, the arguments provided with the command.
                  Example, if the command is "/jabber alias add abc abc@server.tld"
                  argv = ['add', 'abc', 'abc@server.tld']
        """
        self.buffer = buffer
        self.argv = []
        if argv:
            self.argv = argv
        self.action = ''
        self.jid = ''
        self.alias = ''
        self.parse()
        return

    def add(self):
        """Run a "/jabber alias add" command"""
        global jabber_jid_aliases
        if not self.alias or not self.jid:
            weechat.prnt("", "\njabber: unable to add alias, missing arguments")
            weechat.prnt("", "jabber: usage: /jabber alias add alias_name jid")
            return
        # Restrict the character set of aliases. The characters must be writable to
        # config file.
        invalid_re = re.compile(r'[^a-zA-Z0-9\[\]\\\^_\-{|}@\.]')
        if invalid_re.search(self.alias):
            weechat.prnt("", "\njabber: invalid alias: %s" % self.alias)
            weechat.prnt("", "jabber: use only characters: a-z A-Z 0-9 [ \ ] ^ _ - { | } @ .")
            return
        # Ensure alias and jid are reasonable length.
        max_len = 64
        if len(self.alias) > max_len:
            weechat.prnt("", "\njabber: invalid alias: %s" % self.alias)
            weechat.prnt("", "jabber: must be no more than %s characters long" % max_len)
            return
        if len(self.jid) > max_len:
            weechat.prnt("", "\njabber: invalid jid: %s" % self.jid)
            weechat.prnt("", "jabber: must be no more than %s characters long" % max_len)
            return
        jid = self.jid.encode("utf-8")
        alias = self.alias.encode("utf-8")
        if alias in jabber_jid_aliases.keys():
            weechat.prnt("", "\njabber: unable to add alias: %s" % (alias))
            weechat.prnt("", "jabber: alias already exists, delete first")
            return
        if jid in jabber_jid_aliases.values():
            weechat.prnt("", "\njabber: unable to add alias: %s" % (alias))
            for a, j in jabber_jid_aliases.iteritems():
                if j == jid:
                    weechat.prnt("", "jabber: jid '%s' is already aliased as '%s', delete first" %
                        (j, a))
                    break
        jabber_jid_aliases[alias] = jid
        self.alias_reset(jid)
        return

    def alias_reset(self, jid):
        """Reset objects related to the jid modified by an an alias command

        Update any existing buddy objects, server nicklists, and chat objects
        that may be using the buddy with the provided jid.
        """
        global jabber_servers
        for server in jabber_servers:
            buddy = server.search_buddy_list(jid, by='jid')
            if not buddy:
                continue
            server.update_nicklist(buddy=buddy, action='remove')
            buddy.set_alias()
            server.update_nicklist(buddy=buddy, action='update')
            if buddy.chat:
                switch_to_buffer = False
                if buddy.chat.buffer == self.buffer:
                    switch_to_buffer = True
                buddy.chat.delete()
                new_chat = server.add_chat(buddy)
                if switch_to_buffer:
                    weechat.buffer_set(new_chat.buffer, "display", "auto")
        return

    def delete(self):
        """Run a "/jabber alias del" command"""
        global jabber_jid_aliases
        if not self.alias:
            weechat.prnt("", "\njabber: unable to delete alias, missing arguments")
            weechat.prnt("", "jabber: usage: /jabber alias del alias_name")
            return
        if not self.alias in jabber_jid_aliases:
            weechat.prnt("", "\njabber: unable to delete alias '%s', not found" % (self.alias))
            return
        jid = jabber_jid_aliases[self.alias]
        del jabber_jid_aliases[self.alias]
        self.alias_reset(jid)
        return

    def list(self):
        """Run a "/jabber alias" command to list aliases"""
        global jabber_jid_aliases
        weechat.prnt("", "")
        if len(jabber_jid_aliases) <= 0:
            weechat.prnt("", "jabber: no aliases defined")
            return
        weechat.prnt("", "jabber jid aliases:")
        len_alias = 5
        len_jid = 5
        for alias, jid in jabber_jid_aliases.iteritems():
            if len_alias < len(alias):
                len_alias = len(alias)
            if len_jid < len(jid):
                len_jid = len(jid)
        prnt_format = "  %-" + str(len_alias) + "s %-" + str(len_jid) + "s"
        weechat.prnt("", prnt_format % ('Alias', 'JID'))
        for alias, jid in sorted(jabber_jid_aliases.iteritems()):
            weechat.prnt("", prnt_format % (alias, jid))
        #FIXME \\\
        import sys
        weechat.prnt('', "jabber: sys.version: %s" % (sys.version))        # FIXME
        #FIXME ///
        return

    def parse(self):
        """Parse the alias command into components"""
        if len(self.argv) <= 0:
            return
        self.action = self.argv[0]
        if len(self.argv) > 1:
            # Pad argv list to prevent IndexError exceptions
            while len(self.argv) < 3: self.argv.append('')
            self.alias = self.argv[1]
            self.jid = self.argv[2]
        return

    def run(self):
        """Execute the alias command."""
        if self.action == 'add':
            self.add()
        elif self.action == 'del':
            self.delete()
        self.list()
        return

def jabber_completion_servers(data, completion_item, buffer, completion):
    """ Completion with jabber server names. """
    global jabber_servers
    for server in jabber_servers:
        weechat.hook_completion_list_add(completion, server.name,
                                         0, weechat.WEECHAT_LIST_POS_SORT)
    return weechat.WEECHAT_RC_OK

def jabber_completion_jid_aliases(data, completion_item, buffer, completion):
    """ Completion with jabber alias names. """
    global jabber_jid_aliases
    for alias, jid in sorted(jabber_jid_aliases.iteritems()):
        weechat.hook_completion_list_add(completion, alias,
                                         0, weechat.WEECHAT_LIST_POS_SORT)
    return weechat.WEECHAT_RC_OK

# ==================================[ fd ]====================================

def jabber_fd_cb(data, fd):
    """ Callback for reading socket. """
    global jabber_servers
    for server in jabber_servers:
        if server.sock == int(fd):
            server.recv()
    return weechat.WEECHAT_RC_OK

# ================================[ buffers ]=================================

def jabber_buffer_input_cb(data, buffer, input_data):
    """ Callback called for input data on a jabber buffer. """
    context = jabber_search_context(buffer)
    if context["server"] and context["chat"]:
        context["chat"].send_message(input_data)
    elif context["server"]:
        if input_data == "buddies" or "buddies".startswith(input_data):
            context["server"].display_buddies()
        else:
            context["server"].send_message_from_input(input=input_data)
    return weechat.WEECHAT_RC_OK

def jabber_buffer_close_cb(data, buffer):
    """ Callback called when a jabber buffer is closed. """
    context = jabber_search_context(buffer)
    if context["server"] and context["chat"]:
        if context["chat"].buddy:
            context["chat"].buddy.chat = None
        context["chat"].buffer = ""
        context["server"].chats.remove(context["chat"])
    elif context["server"]:
        context["server"].buffer = ""
    return weechat.WEECHAT_RC_OK

# ==================================[ timers ]==================================

def jabber_ping_timeout_timer(server_name, remaining_calls):
    server = jabber_search_server_by_name(server_name)
    if server:
        server.ping_time_out()
    return weechat.WEECHAT_RC_OK

def jabber_ping_timer(server_name, remaining_calls):
    server = jabber_search_server_by_name(server_name)
    if server:
        server.ping()
    return weechat.WEECHAT_RC_OK

# ==================================[ main ]==================================

if __name__ == "__main__" and import_ok:
    if weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION,
                        SCRIPT_LICENSE, SCRIPT_DESC,
                        "jabber_unload_script", ""):
        jabber_hook_commands_and_completions()
        jabber_config_init()
        jabber_config_read()
        for server in jabber_servers:
            if weechat.config_boolean(server.options['autoreconnect']):
                server.ping()               # This will connect and update ping status
                server.add_ping_timer()
            else:
                if weechat.config_boolean(server.options['autoconnect']):
                    server.connect()

# ==================================[ end ]===================================

def jabber_unload_script():
    """ Function called when script is unloaded. """
    global jabber_servers
    jabber_config_write()
    for server in jabber_servers:
        server.disconnect()
        server.delete()
    return weechat.WEECHAT_RC_OK
