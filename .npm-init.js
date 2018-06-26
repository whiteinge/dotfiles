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
const srcIndex = path.join(srcDir, 'index.js');
const testIndex = path.join(testDir, 'index.js');
const build = path.join(distDir, `${basename}.js`);
const min = path.join(distDir, `${basename}.min.js`);

const tscArgs = `--jsx react --allowJs -t es5 -m commonjs`;
const browserifyArgs = `${srcIndex} -p [ tsify ${tscArgs} ]`;

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
        'eslint': '5.x.x',
        'json-server': '0.12.x',
        'npm-run-all': '4.x.x',
        'postbuild': '2.x.x',
        'prettier': '1.x.x',
        'shx': '0.2.x',
        'tap-spec': '5.x.x',
        'tape': '4.x.x',
        'ts-node': '2.x.x',
        'tsify': '4.x.x',
        'typescript': '2.x.x',
        'uglify-js': '2.x.x',
        'watch': '1.x.x',
        'watchify': '3.x.x',
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
        'init:dist': `shx mkdir -p ${distDir}`,
        'init:build': `shx touch ${build}`,

        'build:index': `postbuild -i index.tmpl -o ${distDir}/index.html -j ${build} -g ${distDir}`,
        'prebuild:index': `run-s init:dist init:build`,

        'build:ts': `tsc ${tscArgs} --outDir ${distDir} ${srcDir}/* ${testDir}/*`,
        'watch:ts': `npm run -s build:ts -- -w`,

        'build:prod': `NODE_ENV=production npm -s run build:browserify | uglifyjs > ${min}`,
        'prebuild:prod': `run-s init:dist`,
        'postbuild:prod': `gzip -c ${min} > ${min}.gz`,

        'build:browserify': `browserify ${browserifyArgs}`,
        'watch:browserify': `watchify ${browserifyArgs} --debug -o ${build}`,
        'prebuild:browserify': `run-s init:dist`,
        'prewatch:browserify': `run-s init:dist`,

        'watch:db': `json-server -w ./${distDir}/${basename}-db.json --static ./${distDir}`,
        'prewatch:db': `run-s init:dist build:index`,

        'test': `run-p test:*`,
        'pretest': `npm run build:ts`,
        'test:lint': `eslint ${srcDir}`,
        'test:tape': `run-s repl -- ${testDir}/**/*.js | tap-spec`,

        'repl': `ts-node -D -F -O '{\"allowJs\": true}'`,

        'start': `run-p watch:browserify watch:db`,
        'post:install': `run-s init:dist`,
        'preversion': `npm run build:prod`,
    },
};
