setl foldmethod=indent
setl foldnestmax=1

if exists("+omnifunc")
    setl omnifunc=javascriptcomplete#CompleteJS
endif

setl keywordprg=sh\ -c\ 'lynx\ https://developer.mozilla.org/en-US/search\?q=\$1\ '\ --
