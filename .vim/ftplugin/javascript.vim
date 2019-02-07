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

let g:tagbar_type_javascript = {
    \ 'kinds': [
        \ 'V:variables',
        \ 'A:arrays',
        \ 'C:classes',
        \ 'E:exports',
        \ 'F:functions',
        \ 'G:generators',
        \ 'I:imports',
        \ 'M:methods',
        \ 'P:properties',
        \ 'O:objects',
        \ 'T:tags',
    \ ],
\ }

" Persistent macro to sort ES6 imports.
nmap <leader>qi f{\js,i{vi{!sort\jj,i{k2J2J\fg
