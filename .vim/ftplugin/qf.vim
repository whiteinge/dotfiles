setl nowrap
setl nobuflisted
setl norelativenumber
setl number

" Exit Vim if the quickfix is the last open window.
au BufEnter <buffer> nested if winnr('$') < 2 | q | endif

" Always move the cursor to the current quickfix item when entering the buffer.
au BufEnter <buffer> nested exe getqflist({'id': 0, 'idx': 0}).idx
