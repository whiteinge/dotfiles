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

fu! pick#SwitchBuf(in, ...)
    let l:GetData = function(a:in)
    let l:SwitchBuf = a:0 >= 1 ? function(a:1) : {x -> x}
    let l:FmtRet = a:0 >= 2 ? function(a:2) : {x -> x}

    let l:curwin = win_getid()
    let l:curbuf = bufnr('%')
    let l:curalt = bufnr('#')
    below new
    setl buftype=nofile bufhidden=hide nobuflisted
    let l:inbuf = bufnr('%')
    call l:GetData()
    " Uncomment for a full-window picker instead.
    " close

    " Switch (or restore) buffer and alternate buffers.
    fu! BufCb(ret) closure
        call win_gotoid(l:curwin)
        let l:newbuf = l:FmtRet(trim(a:ret))

        if (l:newbuf == l:curbuf || l:newbuf == '')
            return
        endif

        call l:SwitchBuf(l:newbuf)
        silent! let @# = l:curbuf
        exe l:inbuf .'bwipeout'
    endfu

    call pick#Pick('BufCb', l:inbuf)
endfu

" Open pick#Pick with the current buffer list (:ls)
fu! pick#Buf()
    redir @m | silent ls | redir END

    fu! GetData()
        1put m
        1,2delete
    endfu

    fu! FmtRet(ret)
        return substitute(a:ret, '^ *\([0-9]\+\).*$', '\1', '')
    endfu

    fu! SwitchBuf(newbuf)
        exe 'b '. a:newbuf
    endfu

    call pick#SwitchBuf('GetData', 'SwitchBuf', 'FmtRet')
endfu

fu! pick#Shell(shellin)
    fu! GetData() closure
        exe 'read !'. a:shellin
    endfu

    fu! SwitchBuf(newbuf)
        exe 'e '. a:newbuf
    endfu

    call pick#SwitchBuf('GetData', 'SwitchBuf')
endfu
