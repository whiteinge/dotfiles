/**
Quickly get a new project up and running

Transpiles ES6 and produces Node and browser builds. Quick start:
npm init -y
npm i
npm start

Browserified sandbox:
npm i rx
echo "import * as Rx from 'rx'; window.Rx = Rx" > src/index.js
npm run start:browser

Node console sandbox:
npm i rx
echo "import * as Rx from 'rx'; console.log('rx', Rx);" > src/index.js
npm run start:node
**/

const fs = require('fs');
const path = require('path');

const parseBool = str => ['y', 'yes'].includes(str.toLowerCase());
const set = (name, def, infmt, outfmt = x => x) =>
    yes ? def : prompt(name, package[name] ? outfmt(package[name]) : def, infmt);

const srcDir = 'src';
const distDir = 'dist';
const testDir = 'tests';

const main = path.join(distDir, srcDir, 'index.js');
const src = path.join(srcDir, 'index.js');
const min = path.join(distDir, `${basename}.min.js`);

const tscArgs = `--allowJs -t es5 -m commonjs --outDir ${distDir} ${srcDir}/* ${testDir}/*`;

// Create .gitignore file.
const gitignore = path.join(dirname, '.gitignore');
if (!fs.existsSync(gitignore)) fs.writeFileSync(gitignore, `
/dist
/node_modules
`);

// Create HTML template.
const index = path.join(dirname, 'index.tmpl');
if (!fs.existsSync(index)) fs.writeFileSync(index, `
<!doctype html>
<html lang=en>
<head>
    <meta charset=utf-8>
    <title>${basename}</title>
    <!-- inject:git-hash -->
</head>
<body>
    <div id="container"></div>
    <!-- inject:js -->
    <!-- endinject -->
</body>
</html>
`);

// Scaffold common dirs.
[srcDir, testDir].forEach(function(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
        fs.writeFileSync(path.join(dirname, dir, 'index.js'), '');
    };
});

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
    main: main,
    repository: set('repository', '', x => x, x => x.url),
    homepage: set('homepage', ''),

    dependencies: package.dependencies || {},
    optionalDependencies: package.optionalDependencies || {},
    devDependencies: package.devDependencies || {
        'browserify': '14.x.x',
        'json-server': '0.12.x',
        'npm-run-all': '4.x.x',
        'postbuild': '2.x.x',
        'shx': '0.2.x',
        'tap-spec': '4.x.x',
        'tape': '4.x.x',
        'ts-node': '2.x.x',
        'ts-watch': '1.x.x',
        'typescript': '2.x.x',
        'uglify-js': '2.x.x',
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
        'build': `NODE_ENV=production run-s build:all`,
        'build:all': `run-s build:ts build:browser`,
        'build:browser': cb => cb(null, `browserify ${main} | uglifyjs > ${min}`),
        'build:ts': `tsc ${tscArgs}`,
        'log': `clear && node ${main}`,
        'presrv:browser': `shx mkdir -p ${distDir}`,
        'postbuild:browser': `postbuild -i index.tmpl -o ${distDir}/index.html -j ${min} -g ${distDir}`,
        'preversion': `npm run build`,
        'repl': `ts-node -D -F -O '{\"allowJs\": true}'`,
        'srv:browser': `json-server ./${distDir}/${basename}-db.json --static ./${distDir}`,
        'start': `run-s start:browser`,
        'start:browser': `run-p watch:browser srv:browser`,
        'start:node': `run-s watch:log`,
        'test': `run-p test:*`,
        'test:lint': `eslint ${srcDir}`,
        'test:tape': `run-s repl -- ${testDir}/**/*.js | tap-spec`,
        'watch:browser': `npm -s run watch:ts -- --onSuccess 'npm run-s build:browser'`,
        'watch:log': `npm -s run watch:ts -- --onSuccess 'npm run-s log'`,
        'watch:ts': `ts-watch ${tscArgs}`,
    },
};
