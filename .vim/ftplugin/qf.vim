setl nowrap
setl nobuflisted
setl norelativenumber
setl number

" Exit Vim if the quickfix is the last open window.
au BufEnter <buffer> nested if winnr('$') < 2 | q | endif

" Make the quickfix file paths (a lot) shorter.
au BufReadPost <buffer> setl modifiable
    \ | silent exe '%s/^[^\|]*/\=fp#ShortPath(submatch(0))/'
    \ | setl nomodifiable
