" Make the current buffer a scratch buffer

fu! scratch#Scratch()
    setl buftype=nofile bufhidden=delete nobuflisted
    echo "This file is now a scratch file!"
    return bufnr()
endfu

" call setbufline(bufnr, 1, 'some text')
fu! scratch#Scratchadd()
    let l:bufnr = bufadd('')

    call bufload(l:bufnr)
    call setbufvar(l:bufnr, '&buftype', 'nofile')
    call setbufvar(l:bufnr, '&bufhidden', 'delete')

    return l:bufnr
endfu
