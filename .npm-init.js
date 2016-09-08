module.exports = {
    name: prompt('name', package.name || basename),
    author: 'Seth House <seth@eseth.com> (http://eseth.org)',
    version: prompt('version', package.version || '1.0.0'),
    license: package.license || prompt('license', 'Apache-2.0'),
    description: package.description || prompt('description', ''),
    private: package.private || prompt('private', 'false', JSON.parse),
    keywords: package.keywords || prompt('keywords', '', val =>
            val.split(' ').filter(String)),
    main: prompt('main', package.main || 'index.js'),
    repository: package.repository || prompt('repository', ''),
    homepage: package.homepage || prompt('homepage', '', val =>
        val !== '' ? val : `${module.exports.repository}#readme`),

    dependencies: package.dependencies || {},
    optionalDependencies: package.optionalDependencies || {},
    devDependencies: package.devDependencies || {
        'tape': '~4.6.0',
    },

    eslintConfig: package.eslintConfig || {
        env: {
            browser: true,
            node: true,
        },
        rules: {
        },
    },

    scripts: package.scripts || prompt('Babel?', 'true', function(val) {
        if (JSON.parse(val) === false) {
            return {
                test: 'tape tests.js tests/**/*.js',
            };
        }

        module.exports.main = 'dist/build.js';
        module.exports.devDependencies['babel-preset-es2015'] = '~6.14.0';
        module.exports.eslintConfig.parser = 'babel-eslint';
        module.exports.eslintConfig.env['es6'] = true;
        module.exports.eslintConfig.ecmaFeatures = {
            modules: true,
        };

        return {
            test: 'tape -r babel-register tests.js tests/**/*.js',
            build: `browserify --standalone ${module.exports.name} -t rollupify -t babelify -t uglifyify index.js -o dist/build.js`,
            preversion: 'npm run build',
        };
    }),
}
