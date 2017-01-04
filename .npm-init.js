module.exports = {
    name: prompt('name', package.name || basename),
    author: 'Seth House <seth@eseth.com> (http://eseth.org)',
    version: prompt('version', package.version || '1.0.0'),
    license: package.license || prompt('license', 'Apache-2.0'),
    description: package.description || prompt('description', ''),
    private: package.private || prompt('private', 'false', JSON.parse),
    keywords: package.keywords || prompt('keywords', '', val =>
            val.split(' ').filter(String)),
    main: prompt('main', package.main || 'lib/src/index.js'),
    repository: package.repository || prompt('repository', ''),
    homepage: package.homepage || prompt('homepage', '', val =>
        val !== '' ? val : `${module.exports.repository}#readme`),

    dependencies: package.dependencies || {},
    optionalDependencies: package.optionalDependencies || {},
    devDependencies: package.devDependencies || {
        'tape': '4.x.x',
        'typescript': '2.x.x',
        'ts-node': '2.x.x',
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
        test: `ts-node -D -F -O '{\"allowJs\": true}' node_modules/tape/bin/tape tests/**/*.js`,
        build: 'tsc --allowJs -m umd --outDir lib src/* tests/*',
        preversion: 'npm run build',
    },
}
