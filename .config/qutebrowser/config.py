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
    'open -t https://mail.google.com/mail/u/0/#inbox',
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
c.url.searchengines['youtube'] = 'https://www.youtube.com/results?search_query={}'

c.aliases['github-first-commit'] = """jseval javascript:(b=>fetch('https://api.github.com/repos/'+b[1]+'/commits?sha='+(b[2]||'')).then(c=>Promise.all([c.headers.get('link'),c.json()])).then(c=>{if(c[0]){var d=c[0].split(',')[1].split(';')[0].slice(2,-1);return fetch(d).then(e=>e.json())}return c[1]}).then(c=>c.pop().html_url).then(c=>window.location=c))(window.location.pathname.match(/\/([^\/]+\/[^\/]+)(?:\/tree\/([^\/]+))?/));"""
c.aliases['video-1x'] = """jseval javascript:(function(){document.querySelector('video').playbackRate=1})()"""
c.aliases['video-1.5x'] = """jseval javascript:(function(){document.querySelector('video').playbackRate=1.5})()"""
c.aliases['video-2x'] = """jseval javascript:(function(){document.querySelector('video').playbackRate=2})()"""
c.aliases['audio-1x'] = """jseval javascript:(function(){document.querySelector('audio').playbackRate=1})()"""
c.aliases['audio-1.5x'] = """jseval javascript:(function(){document.querySelector('audio').playbackRate=1.5})()"""
c.aliases['audio-2x'] = """jseval javascript:(function(){document.querySelector('audio').playbackRate=2})()"""
c.aliases['larder-add'] = """jseval javascript:(function(){if(window.LarderBM!==undefined){LarderBM();}else{document.head.appendChild(document.createElement('script')).src='https://larder.io/static/js/bookmarklet.js?667829';}})();"""

# Enable spell check
# /usr/share/qutebrowser/scripts/dictcli.py install en-US
# set spellcheck.languages ["en-US"]

# Minimize fingerprinting:
# set content.headers.user_agent. Another, possibly more generic user-agent is:
# Mozilla/5.0 (Windows NT 6.1; rv:52.0) Gecko/20100101 Firefox/52.0

# set content.headers.accept_language en-US,en;q=0.5
# set content.headers.custom '{"accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}'
