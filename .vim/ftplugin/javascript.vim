if exists("+omnifunc")
    setl omnifunc=javascriptcomplete#CompleteJS
endif

" tagbar settings
if ! executable('jsctags')
    let g:tagbar_type_javascript = {
        \ 'kinds' : [
            \ 'c:classes',
            \ 'm:methods',
            \ 'f:functions',
            \ 'v:global variables:0:0',
            \ 'p:properties:1:0',
        \ ],
    \ }
endif
