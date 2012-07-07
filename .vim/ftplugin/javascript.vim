if exists("+omnifunc")
    setl omnifunc=javascriptcomplete#CompleteJS
endif

if has("autocmd")
    au BufWritePost *.js silent! !ctags -R %:p:h
endif
