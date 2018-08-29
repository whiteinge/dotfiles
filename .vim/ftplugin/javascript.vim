setl foldmethod=indent
setl foldnestmax=1

if exists("+omnifunc")
    setl omnifunc=javascriptcomplete#CompleteJS
endif

setl keywordprg=sh\ -c\ 'lynx\ https://developer.mozilla.org/en-US/search\?q=\$1\ '\ --

let b:ale_fixers = ['prettier']
let b:ale_linters_ignore = ['prettier']
let b:ale_javascript_prettier_use_local_config = 1
let b:ale_javascript_eslint_options = "--rule 'prettier/prettier: 0'"
