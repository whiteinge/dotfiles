/**
Quickly get a new browser or Node project up and running with transpilation
development API and production bundles.
**/

const fs = require('fs');
const path = require('path');

const parseBool = str => ['y', 'yes'].includes(str.toLowerCase());
const get = (path, obj) =>
    path.split('.').reduce((acc, current) => acc && acc[current], obj);
const set = (name, def, infmt, outfmt = x => x) =>
    yes ? def : prompt(name, package[name] ? outfmt(package[name]) : def, infmt);

const srcDir = 'src';
const distDir = 'dist';
const testDir = path.join(srcDir, '__tests__');

const main = path.join(distDir, 'index.js');
const srcIndex = path.join(srcDir, 'index.js');
const testIndex = path.join(testDir, 'index-test.js');
const build = path.join(distDir, `${basename}.js`);
const min = path.join(distDir, `${basename}.min.js`);

const tsconfig = path.join(dirname, 'tsconfig.json');
if (!fs.existsSync(tsconfig)) fs.writeFileSync(tsconfig, JSON.stringify({
    include: [srcDir],
    compilerOptions: {
        allowJs: true,
        skipLibCheck: true,
        jsx: 'react',
        module: 'commonjs',
        target: 'es5',
        rootDir: 'src',
        outDir: distDir,
        sourceMap: false,
        inlineSourceMap: true,
        inlineSources: true,
        types: [],
    },
}, null, 4));

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
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${basename}</title>
</head>
<body>
    <div id="container"></div>
    <!-- inject:js -->
</body>
</html>
`);

// Scaffold common dirs.
[srcDir, testDir].forEach(function(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    };
});
[srcIndex, testIndex].forEach(function(fpath) {
    if (!fs.existsSync(fpath)) {
        fs.writeFileSync(fpath, '');
    };
});

// Create perf/mem test scaffolds.
const memTest = path.join(dirname, testDir, 'mem.js')
const perfTest = path.join(dirname, testDir, 'perf.js')

if (!fs.existsSync(memTest)) fs.writeFileSync(memTest, `
const used = process.memoryUsage();
for (let key in used) {
    console.log(\`\${key} \${Math.round(used[key] / 1024 / 1024 * 100) / 100} MB\`);
}
`)

if (!fs.existsSync(perfTest)) fs.writeFileSync(perfTest, `
import {Benchmark} from 'benchmark'
const suite = new Benchmark.Suite()

const testData = Array.from({length: 10000}, (x, i) => i)
const addOne = x => x + 1

suite
  .add('forOfFn', () => {
    const ret = []
    for(const x of testData) {
        ret.push(x + 1)
    }
    return ret
  })
  .add('mapFn', () => testData.map(x => x + 1))
  .add('mapFn2', () => testData.map(addOne))
  .on('cycle', (ev) => { console.log(String(ev.target)) })
  .on('complete', function() {
    console.log('Fastest is ' + this.filter('fastest').map('name'))
  })
  .run({ async: true })
`)

module.exports = {
    name: set('name', basename),
    // author: set('author', config.defaults['init.author.name'] || '',
    author: set('author', `${config.env['npm_config_init.author.name']} <${config.env['npm_config_init.author.email']}> (${config.env['npm_config_init.author.url']})`),
    version: set('version', '1.0.0'),
    license: set('license', config.env['npm_config_init.license'] || 'Apache-2.0'),
    description: set('description', ''),
    'private': set('private', false, parseBool, JSON.stringify),
    keywords: set('keywords',  '',
        val => val.split(',').filter(String).map(x => x.trim()),
        val => val.join(', ')),
    main: main,
    type: 'module',
    repository: set('repository', '', x => x, x => x.url),
    homepage: set('homepage', ''),

    prettier: JSON.stringify({
        bracketSpacing: false,
        parser: 'typescript',
        singleQuote: true,
        tabWidth: 4,
        trailingComma: 'all',
    }),

    dependencies: package.dependencies || {},
    optionalDependencies: package.optionalDependencies || {},
    devDependencies: package.devDependencies || {
        'benchmark': '2.x.x',
        'prettier': '2.x.x',
        'uvu': '0.x.x',
        'typescript': '2.x.x',
        'watchlist': '0.x.x',
        'sirv-cli': '1.x.x',
    },

    scripts: package.scripts || {
        'build:index': `sed -e 's@<!-- inject:js -->@<script src="/${basename}.min.js"></script>@g' index.tmpl > ${distDir}/index.html`,

        'build:prod': `NODE_ENV=production npm -s run build:browserify`,
        'prebuild:prod': 'NODE_ENV=production npm run -s build:node',
        'postbuild:prod': `gzip -c ${min} > ${min}.gz; npm run -s build:stats`,

        'test': `uvu ${srcDir}`,
        'pretest': `npm run build:node`,

        'start': 'sirv --dev --etag --gzip --brotli --maxage --port 8000',

        'preversion': `npm run build:prod`,

        'watch:test': `watchlist ${srcDir} -- npm test`,
    },
};
