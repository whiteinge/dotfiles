" Open Pick in a :terminal and :edit the picked result
"
" pick#Pick('foo\nbar\nbaz\n')
" pick#Pick('foo', 'bar', 'baz')
fu! pick#Pick(...)
    let s:str = join(a:000, '\n') .'\n'

    let s:tbuf = term_start([$SHELL, '-c', "printf '". s:str ."' | pick | xargs"],
        \ {'curwin': 1, 'out_cb': 'SaveMsg', 'close_cb': 'LastMsg'})

    let s:lastmsg = ""
    fu! SaveMsg(channel, msg)
        " Ignore stdout while in an altscreen. We just want the end result.
        if (! term_getaltscreen(s:tbuf))
            let s:lastmsg = a:msg
        endif
    endfu
    fu! LastMsg(channel)
        exe 'b '. trim(s:lastmsg)
    endfu
endfu

fu! pick#Buf()
    call fp#Pipe([
        \ fp#Filter({v -> buflisted(v)}),
        \ fp#Map({v -> bufname(v)}),
        \ {xs -> call('pick#Pick', xs)},
    \ ])(range(1, bufnr('$')))
endfu
