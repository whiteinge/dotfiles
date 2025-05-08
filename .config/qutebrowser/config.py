# ruff: noqa F821

import os
os.environ['PATH'] = f'{os.environ["HOME"]}/bin:' + os.environ['PATH']

config.load_autoconfig(False)

c.qt.args = ['widevine-path=/does/not/exist']

config.set('content.autoplay', True)
config.set('content.blocking.enabled', True)
config.set('content.headers.do_not_track', False)
config.set('content.javascript.enabled', True)
config.set('content.persistent_storage', True)
config.set('content.geolocation', 'ask')
config.set('content.register_protocol_handler', False)

config.set('content.desktop_capture', True, '*://*.google.com/*')
config.set('content.geolocation', True, '*://*.google.com/*')
config.set('content.geolocation', True, '*://*.homedepot.com/*')
config.set('content.javascript.clipboard', 'access-paste', '*://github.com/*')
config.set('content.javascript.clipboard', 'access-paste', '*://search.brave.com/*')
config.set('content.media.audio_capture', True, '*://*.google.com/*')
config.set('content.media.audio_video_capture', True, '*://*.google.com/*')
config.set('content.media.video_capture', True, '*://*.google.com/*')
config.set('content.notifications.enabled', True, '*://*.gitlab.com/*')
config.set('content.notifications.enabled', True, '*://*.google.com/*')

c.confirm_quit = ['always']
c.window.hide_decoration = True
c.downloads.location.prompt = False
c.auto_save.session = True

c.editor.command = ['xterm', '-e', 'vim -f {file} -c "normal {line}G{column0}l"']

c.tabs.background = True
c.tabs.mousewheel_switching = False
c.tabs.title.format_pinned = '{index}'
c.tabs.title.format = '{private}{audio}{index}{title_sep}{current_title}'

font = '12pt monospace'
c.fonts.statusbar = font
c.fonts.statusbar = font
c.fonts.tabs.selected = font
c.fonts.tabs.unselected = font
c.fonts.hints = font
c.fonts.keyhint = font

c.url.default_page = 'about:blank'
c.url.start_pages = 'about:blank'

config.bind('-', 'cmd-set-text -s :tab-select')
config.bind('gT', 'tab-prev')
config.bind('gt', 'tab-focus')
config.bind('y', 'yank url')
config.bind('<ctrl-e>', 'scroll down')
config.bind('<ctrl-y>', 'scroll up')
config.bind('p', 'hint links run :open -p {hint-url}')
config.bind('P', 'open -p ')

config.bind(r'\j', 'config-cycle content.javascript.enabled')
config.bind(r'\u', 'spawn -u quterun')

config.bind('<Ctrl-a>', 'fake-key <Home>', mode='insert')
config.bind('<Ctrl-e>', 'fake-key <End>', mode='insert')
config.bind('<Ctrl-d>', 'fake-key <Delete>', mode='insert')
config.bind('<Ctrl-y>', 'insert-text {primary}', mode='insert')
config.bind('<Ctrl-w>', 'fake-key <Ctrl-backspace>', mode='insert')
config.bind('<Ctrl-u>', 'fake-key <Shift+Home> ;; fake-key <Delete>', mode='insert')

c.url.searchengines['DEFAULT'] = 'https://search.brave.com/search?q={}'
c.url.searchengines['caniuse'] = 'http://caniuse.com/#search={}'
c.url.searchengines['dev'] = 'https://devdocs.io/#q={}'
c.url.searchengines['dict'] = 'http://dictionary.reference.com/browse/{}'
c.url.searchengines['mdn'] = 'https://developer.mozilla.org/en-US/search?q={}'
c.url.searchengines['npm'] = 'https://www.npmjs.com/search?q={}'
c.url.searchengines['pypi'] = 'https://pypi.python.org/pypi?%3Aaction=search&term={}&submit=search'
c.url.searchengines['python'] = 'https://docs.python.org/3.5/search.html?q={}&check_keywords=yes&area=default'
c.url.searchengines['steam'] = 'http://store.steampowered.com/search/?ref=os&term={}'
c.url.searchengines['unpkg'] = 'https://unpkg.com/{}/'
c.url.searchengines['youtube'] = 'https://www.youtube.com/results?search_query={}'

c.aliases['xa'] = 'quit --save'

c.aliases['github-first-commit'] = """jseval javascript:(b=>fetch('https://api.github.com/repos/'+b[1]+'/commits?sha='+(b[2]||'')).then(c=>Promise.all([c.headers.get('link'),c.json()])).then(c=>{if(c[0]){var d=c[0].split(',')[1].split(';')[0].slice(2,-1);return fetch(d).then(e=>e.json())}return c[1]}).then(c=>c.pop().html_url).then(c=>window.location=c))(window.location.pathname.match(/\/([^\/]+\/[^\/]+)(?:\/tree\/([^\/]+))?/));"""
c.aliases['audio-speed'] = """jseval javascript:(() => {var speed = window.prompt('Speed x', 3); document.querySelectorAll('audio').forEach(x => x.playbackRate = speed);})();"""
c.aliases['video-speed'] = """jseval javascript:(() => {var speed = window.prompt('Speed x', 3); document.querySelectorAll('video').forEach(x => x.playbackRate = speed);})();"""
c.aliases['video-2x'] = """jseval javascript:(() => {var speed = 2; document.querySelectorAll('video').forEach(x => x.playbackRate = speed);})();"""
c.aliases['audio-2x'] = """jseval javascript:(() => {var speed = 2; document.querySelectorAll('audio').forEach(x => x.playbackRate = speed);})();"""
c.aliases['reload-css'] = """jseval javascript:void(function(){var i,a,s;a=document.getElementsByTagName('link');for(i=0;i<a.length;i++){s=a[i];if(s.rel.toLowerCase().indexOf('stylesheet')>=0&&s.href) {var h=s.href.replace(/(&|\?)forceReload=d+/,'');s.href=h+(h.indexOf('?')>=0?'&':'?')+'forceReload='+(new Date().valueOf())}}})();"""
c.aliases['youtube-dislikes'] = """jseval javascript:fetch("https://returnyoutubedislikeapi.com/votes?videoId=" + new URLSearchParams(location.search).get("v")).then((x) => x.json()).then(({ likes, dislikes }) => alert(`Likes: ${likes}; Dislikes: ${dislikes}`));"""
c.aliases['kickass'] = """jseval javascript:var s = document.createElement('script');s.type='text/javascript';document.body.appendChild(s);s.src='https://gistcdn.githack.com/whiteinge/8aafce3b3d8e254c56ef630b0a4c8910/raw/a152b3966f73454fed0cdbe2c1dcab3559388c81/asteroids.js';"""
