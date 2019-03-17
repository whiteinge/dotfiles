" Open Pick in a :terminal and invoke a callback with the picked result
" Reads input from a buffer to avoid escaping issues.
"
" pick#Pick({x -> x}, 1)
" pick#Pick({x -> x}, 1)
" pick#Pick('SomeCallbackFunc', 1)
fu! pick#Pick(cb, inbuf)
    let l:Cb = function(a:cb)
    " Hack: xargs filters ansi escapes we get from the alt screen.
    let l:tbuf = term_start([$SHELL, '-c', 'pick | xargs'], {
        \ 'in_buf': a:inbuf, 'in_io': 'buffer',
        \ 'curwin': 1, 'norestore': 1,
        \ 'eof_chars': 'exit',
        \ 'out_cb': 'SaveMsg', 'exit_cb': 'LastMsg',
        \ 'term_finish': 'close', 'term_name': 'buffers-pick',
    \ })

    let l:lastmsg = ""
    fu! SaveMsg(channel, msg) closure
        " Ignore stdout while in an altscreen. We just want the end result.
        if (! term_getaltscreen(l:tbuf))
            let l:lastmsg = a:msg
        endif
    endfu
    fu! LastMsg(...) closure
        call term_wait(l:tbuf)
        call l:Cb(l:lastmsg)
    endfu
endfu

" Open pick#Pick with the current buffer list (:ls)
fu! pick#Buf()
    let l:curbuf = bufnr('%')
    let l:curalt = bufnr('#')

    redir @m | silent ls | redir END
    botright new
    let l:inbuf = bufnr('%')
    1put m
    1,2delete
    setl buftype=nofile bufhidden=hide nobuflisted
    " Uncomment for a full-window picker instead.
    " close

    fu! s:BufCb(ret) closure
        " Switch (or restore) buffer and alternate buffers.
        let l:msg = trim(substitute(a:ret, '^ *\([0-9]\+\).*$', '\1', ''))
        exe 'b '. (l:msg == '' ? l:curbuf : l:msg)
        silent! let @# = (l:msg == '' ? l:curalt : l:curbuf)
        exe l:inbuf .'bwipeout'
    endfu

    call pick#Pick('s:BufCb', l:inbuf)
endfu
