setl nowrap
setl nobuflisted
setl norelativenumber
setl number

" Exit Vim if the quickfix is the last open window
au BufEnter <buffer> nested if winnr('$') < 2 | q | endif
