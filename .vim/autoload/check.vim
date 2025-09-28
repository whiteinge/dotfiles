" Add a checkprg mechanism to Vim
"
" Vim has :make, &makeprg, and 'compiler'. Those expect the current file is
" already written to disk, are typically used to invoke a build system, and
" display the results in the quickfix list.
"
" This adds a sister mechanism that takes the current in-progress buffer,
" invokes a syntax checker or linter (asyncronously), and displays the results
" in the location list.
"
" It uses b:checkprg and b:checkformat to avoid conflicting with makeprg and
" errorformat. In most cases you can copy those values into new variables.
" Change the value from makeprg to expect stdin instead of a file path.
"
" Look in $VIMRUNTIME/compilers and https://github.com/Konfekt/vim-compilers
" for existing implementations.

fu! s:CloseHandler(channel)
    let l:ret = []
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        call add(l:ret, ch_read(a:channel))
    endwhile

    call setloclist(0, [], 'u', {
        \ 'lines': l:ret,
        \ 'efm': getbufvar(bufnr(), 'checkformat')
    \ })
endfu

fu! s:ErrHandler(channel, msg)
    echoe 'Check: '. a:msg
endfu

fu! check#Check()
    let l:bufnr = bufnr()

    if exists('b:_check_job') && job_status(b:_check_job) == 'run'
        return
    endif
    if ! exists('b:checkprg')
        return
    endif

    let l:command = getbufvar(l:bufnr, 'checkprg') ->expandcmd()
    let b:_check_job = job_start(l:command, {
        \ 'in_io': 'buffer', 'in_buf': l:bufnr,
        \ 'close_cb': function('s:CloseHandler'),
        \ "err_cb": function('s:ErrHandler'),
    \ })
endfu

fu! check#FormatBufferPreserveCursor()
    let l:save_cursor = getcurpos()
    silent! execute "normal! ggVGgq"
    call setpos('.', l:save_cursor)
endfu
