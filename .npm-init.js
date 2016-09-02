module.exports = {
    name: prompt('name', package.name || basename),
    version: prompt('version', '1.0.0'),
    description: prompt('description', ''),
    private: prompt('private', 'false', JSON.parse),
    keywords: prompt('keywords', '', val => val.split(' ').filter(String)),

    author: 'Seth House <seth@eseth.com>',
    license: prompt('license', 'Apache-2.0'),

    scripts: {
        test: 'tape -r babel-register tests/**/*.js',
    },
    devDependencies: {
        'babel-preset-es2015': '~6.14.0',
        'tape': '~4.6.0',
    },
    eslintConfig: {
        parser: 'babel-eslint',
        env: {
            browser: true,
            node: true,
            es6: true,
        },
        ecmaFeatures: {
            modules: true,
        },
        rules: {
        },
    },
}
