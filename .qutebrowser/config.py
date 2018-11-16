config.set('content.javascript.enabled', True, 'file://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')

config.set('content.geolocation', True, 'https://*.google.com/*')
config.set('content.register_protocol_handler', True, 'https://www.irccloud.com/*')
config.set('content.register_protocol_handler', True, 'https://*.google.com/*')
# config.set('content.notifications', True, 'https://*.google.com/*')
# config.set('content.notifications', True, 'https://www.irccloud.com/*')
# config.set('content.notifications', True, 'https://*.slack.com/*')

c.content.cookies.accept = 'all'

c.confirm_quit = ['always']
c.content.autoplay = False

c.tabs.background = True
c.tabs.title.format_pinned = '{index}'
c.tabs.title.format = '{private}{audio}{index}: {title}'

font = '12pt monospace'
c.fonts.statusbar = font
c.fonts.statusbar = font
c.fonts.tabs = font
c.fonts.hints = font
c.fonts.keyhint = font

c.url.default_page = 'about:blank'
c.url.start_pages = 'about:blank'

config.bind('<F1>', 'set-cmd-text -s :buffer')
config.bind('gT', 'tab-prev')
config.bind('gt', 'tab-focus')
config.bind('y', 'yank url')
config.bind('<ctrl-e>', 'scroll down')
config.bind('<ctrl-y>', 'scroll up')
config.bind('p', 'hint links run :open -p {hint-url}')
config.bind('P', 'open -p ')

config.bind(r'\j', 'config-cycle content.javascript.enabled')
config.bind(r'\u', 'spawn -u quterun')

config.bind(r'\w', ';;'.join([
    'open -t https://www.irccloud.com/',
    'tab-pin',
    'open -t https://jane.slack.com/',
    'tab-pin',
    'open -t https://mail.google.com/mail/u/0/#inbox',
    'tab-pin',
    'open -t https://mail.google.com/mail/u/1/#inbox',
    'tab-pin',
    'open -t https://octobox.io/?per_page=100',
    'tab-pin',
]))

c.url.searchengines['audible'] = 'http://www.audible.com/search?advsearchKeywords={}'
c.url.searchengines['caniuse'] = 'http://caniuse.com/#search={}'
c.url.searchengines['cdnjs'] = 'https://cdnjs.com/#q={}'
c.url.searchengines['dev'] = 'https://devdocs.io/#q={}'
c.url.searchengines['dict'] = 'http://dictionary.reference.com/browse/{}'
c.url.searchengines['mdn'] = 'https://developer.mozilla.org/en-US/search?q={}'
c.url.searchengines['npm'] = 'https://www.npmjs.com/search?q={}'
c.url.searchengines['pypi'] = 'https://pypi.python.org/pypi?%3Aaction=search&term={}&submit=search'
c.url.searchengines['python'] = 'https://docs.python.org/3.5/search.html?q={}&check_keywords=yes&area=default'
c.url.searchengines['steam'] = 'http://store.steampowered.com/search/?ref=os&term={}'
c.url.searchengines['unpkg'] = 'https://unpkg.com/{}/'

# Enable spell check
# /usr/share/qutebrowser/scripts/dictcli.py install en-US
# set spellcheck.languages ["en-US"]

# Minimize fingerprinting:
# set content.headers.user_agent. Another, possibly more generic user-agent is:
# Mozilla/5.0 (Windows NT 6.1; rv:52.0) Gecko/20100101 Firefox/52.0

# set content.headers.accept_language en-US,en;q=0.5
# set content.headers.custom '{"accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}'
