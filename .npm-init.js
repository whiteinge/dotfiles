const parseBool = str => ['y', 'yes'].includes(str.toLowerCase());
const set = (name, def, infmt, outfmt = x => x) =>
    yes ? def : prompt(name, package[name] ? outfmt(package[name]) : def, infmt);

module.exports = {
    name: set('name', basename),
    author: set('author', config.sources.user.data.author || '',
        x => x,
        ({name='', email, url}) => name
            .concat(email ? ` <${email}>` : '')
            .concat(url ? ` (${url})` : '')),
    version: set('version', '1.0.0'),
    license: set('license', 'Apache-2.0'),
    description: set('description', ''),
    'private': set('private', 'false', parseBool, JSON.stringify),
    keywords: set('keywords',  '',
        val => val.split(',').filter(String).map(x => x.trim()),
        val => val.join(', ')),
    main: 'dist/src/index.js',
    browser: `dist/${basename}.min.js`,
    repository: set('repository', '', x => x, x => x.url),
    homepage: set('homepage', ''),

    dependencies: package.dependencies || {},
    optionalDependencies: package.optionalDependencies || {},
    devDependencies: package.devDependencies || {
        'shx': '0.2.x',
        'tape': '4.x.x',
        'typescript': '2.x.x',
        'ts-node': '2.x.x',
        'uglify-js': '2.8.x',
    },

    eslintConfig: package.eslintConfig || {
        env: {
            browser: true,
            node: true,
        },
        rules: {
        },
    },

    scripts: package.scripts || {
        'build': 'NODE_ENV=production npm -s run build:tsc; NODE_ENV=production npm -s run build:browser',
        'build:browser': cb => cb(null, `tsc --allowJs -m amd --outFile /dev/stdout | uglifyjs > ${module.exports.browser}`),
        'build:tsc': 'tsc --allowJs -m umd --outDir dist src/* tests/*',
        'install:basedirs': 'shx mkdir -p dist src tests',
        'install:basefiles': 'shx touch src/index.js tests/index.js',
        'postinstall': 'npm run -s install:basedirs; npm run -s install:basefiles',
        'preversion': 'npm run build',
        'test': 'npm -s run test:suite || EXIT=$? npm -s run test:lint || EXIT=$?; exit ${EXIT:-0}',
        'test:lint': 'eslint ./src',
        'test:suite': `ts-node -D -F -O '{\"allowJs\": true}' node_modules/tape/bin/tape tests/**/*.js`,
    },
}
