/**
Quickly get a new browser or Node project up and running with transpilation
development API and production bundles.
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

const tsconfig = path.join(dirname, 'tsconfig.json');
if (!fs.existsSync(tsconfig)) fs.writeFileSync(tsconfig, JSON.stringify({
    include: [srcDir, testDir],
    compilerOptions: {
        allowJs: true,
        skipLibCheck: true,
        jsx: 'react',
        module: 'commonjs',
        target: 'es5',
        rootDir: '.',
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

const server = path.join(dirname, 'server.js');
if (!fs.existsSync(server)) fs.writeFileSync(server, `
const path = require('path');

const polka = require('polka');
const staticdir = require('serve-static');

const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const adapter = new FileSync('./dist/db.json');
const db = low(adapter);

const PORT = process.env.PORT || 8000;
const dir = path.join(__dirname, './dist');

const app = polka()
    .use(staticdir(dir))
    .use((req, rep, next) => {
        let body = '';
        req.on('data', chunk => { body += chunk.toString() });
        req.on('end', () => {
            try { req.body = JSON.parse(body) }
            catch(err) { req.body = body }
            next();
        });
    })
    .use((req, rep, next) => {
        rep.setHeader('Access-Control-Allow-Origin', '*');
        next();
    })
    .use((req, rep, next) => {
        rep.setHeader('Content-Type', 'application/json');
        rep.json = x => rep.end(JSON.stringify(x, null, 4));
        next();
    });

// GET /users
// GET /users?username=foo
app.get('/users', (req, rep) => rep.json(
    db.get('users').filter(req.query).value()));

app.post('/users', (req, rep) => console.log('XXX', req.body) || rep.json(
    db.get('users')
        .thru(xs => {
            const nextID = db._.chain(xs)
                .maxBy('id').get('id', '0')
                .toNumber().add(1).toString()
                .value();
            xs.push(Object.assign(req.body, {id: nextID}));
            return xs;
        })
        .write()));

app.get('/users/:id', (req, rep) => rep.json(
    db.get('users').find(req.params).value()));

app.put('/users/:id', (req, rep) => rep.json(
    db.get('users')
        .find(req.params)
        .thru(x => Object.assign(req.body, {id: x.id}))
        .write()));

app.delete('/users/:id', (req, rep) => rep.json(
    db.get('users').remove(req.params).write()));

db.defaults({users: [{username: 'foo', id: '1'}]}).write();

app.listen(PORT, console.error);
`);

// Create Prettier config.
const prettierConfig = path.join(dirname, '.prettierrc');
if (!fs.existsSync(prettierConfig)) fs.writeFileSync(prettierConfig,
    JSON.stringify({
    bracketSpacing: false,
    parser: 'typescript',
    singleQuote: true,
    tabWidth: 4,
    trailingComma: 'all',
}));

// Scaffold common dirs.
[srcDir, testDir].forEach(function(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
        fs.writeFileSync(path.join(dirname, dir, 'index.js'), '');
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
var Benchmark = require('benchmark')
var suite = new Benchmark.Suite()

suite
  .add('functionName', functionName)
  .on('cycle', function(event) { console.log(String(event.target)) })
  .on('complete', function() {
    console.log('Fastest is ' + this.filter('fastest').map('name'))
  })
  .run({ async: true })
`)

module.exports = {
    name: set('name', basename),
    author: set('author', config.sources.user.data['init.author.name'] || '',
        x => x,
        ({name='', email, url}) => name
            .concat(email ? ` <${email}>` : '')
            .concat(url ? ` (${url})` : '')),
    version: set('version', '1.0.0'),
    license: set('license', 'Apache-2.0'),
    description: set('description', ''),
    'private': set('private', false, parseBool, JSON.stringify),
    keywords: set('keywords',  '',
        val => val.split(',').filter(String).map(x => x.trim()),
        val => val.join(', ')),
    main: main,
    repository: set('repository', '', x => x, x => x.url),
    homepage: set('homepage', ''),

    dependencies: package.dependencies || {},
    optionalDependencies: package.optionalDependencies || {},
    devDependencies: package.devDependencies || {
        'benchmark': '2.x.x',
        'browserify': '16.x.x',
        'lowdb': '1.x.x',
        'polka': '0.5.x',
        'prettier': '1.x.x',
        'serve-static': '1.x.x',
        'source-map-explorer': '2.x.x',
        'tap-spec': '5.x.x',
        'tape': '4.x.x',
        'tsc-watch': '2.x.x',
        'tslib': '1.x.x',
        'typescript': '2.x.x',
        'uglify-js': '3.x.x',
    },

    scripts: package.scripts || {
        'build:index': `sed -e 's@<!-- inject:js -->@<script src="/${basename}.min.js"></script>@g' index.tmpl > ${distDir}/index.html`,
        'build:stats': `source-map-explorer ${min}{,.map} --html ${build}-stats.html`,

        'build:node': 'tsc || true',
        'watch:node': `tsc-watch --onSuccess 'node ${main}'`,

        'build:prod': `NODE_ENV=production npm -s run build:browserify`,
        'prebuild:prod': 'NODE_ENV=production npm run -s build:node',
        'postbuild:prod': `gzip -c ${min} > ${min}.gz; npm run -s build:stats`,

        'build:browserify': `browserify ${main} --debug | uglifyjs --source-map 'url=${min}.map,content=inline' -o ${min}`,
        'postbuild:browserify': 'npm run -s build:index',
        'watch:browserify': `tsc-watch --onSuccess 'npm run -s build:browserify'`,

        'watch:db': `node ${server}`,
        'prewatch:db': `mkdir -p ${distDir}`,

        'test': `tape ${distDir}/${testDir}/**/*.js | tap-spec`,
        'pretest': `npm run build:node`,

        'start': `npm run -s watch:browserify & npm run -s watch:db`,
        'preversion': `npm run build:prod`,
    },
};
