" Add a checkprg mechanism to Vim
"
" Vim has :make, &makeprg, and 'compiler'. Those expect the current file is
" already written to disk, are typically used to invoke a build system, and
" display the results in the quickfix list.
"
" This adds a sister mechanism that takes the current in-progress buffer,
" invokes a syntax checker or linter (asyncronously), and displays the results
" in the location list. Same for a formatter.
"
" It uses b:checkprg / b:checkerrfmt and b:checkformat to avoid conflicting
" with makeprg / errorformat and formatprg. In most cases you can copy those
" values into new variables, but change the value from makeprg to expect stdin
" instead of a file path.
"
" Look in $VIMRUNTIME/compilers and https://github.com/Konfekt/vim-compilers
" for existing implementations.
"
" Use :let b:_check_debug = 1 to see the linter output with :messages to
" compare which lines match b:checkerrfmt.

fu! s:CloseHandler(channel)
    let l:ret = []
    while ch_status(a:channel, {'part': 'out'}) == 'buffered'
        call add(l:ret, ch_read(a:channel))
    endwhile

    if exists('b:_check_debug')
        for l:line in l:ret
            echom 'Check debug: '. l:line
        endfor
    endif

    call setloclist(0, [], 'u', {
        \ 'lines': l:ret,
        \ 'efm': getbufvar(bufnr(), 'checkerrfmt')
    \ })
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
        \ "err_io": "out",
        \ 'close_cb': function('s:CloseHandler'),
    \ })
endfu

fu! check#FormatBufferPreserveCursor()
    if ! exists('b:checkformat')
        return
    endif

    let l:save = winsaveview()
    let l:out = systemlist(b:checkformat, bufnr())

    if v:shell_error != 0
        return
    endif

    call setline(1, l:out)
    call deletebufline(bufnr(), len(l:out) + 1, '$')
    unlet l:out
    call winrestview(l:save)
endfu
