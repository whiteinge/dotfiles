" Stock Vim JavaScript support is bad.
" Proper folding requires the pangloss/vim-javascript plugin.
setl foldmethod=syntax
setl foldnestmax=1

if exists("+omnifunc")
    setl omnifunc=javascriptcomplete#CompleteJS
endif

let g:syntastic_javascript_checkers = ['eslint', 'flow']
let g:syntastic_aggregate_errors = 1
