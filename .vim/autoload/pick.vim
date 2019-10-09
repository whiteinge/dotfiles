" Open a CLI fuzzy-finder in :term and invoke a callback with the result
"
" The workflow for building a new mapping is:
" 1.  Create a new scratch buffer.
" 2.  Populate the buffer however is best for the data you want to filter.
" 3.  Start the terminal which will consume the buffer contents as stdin and
"     take the place of the buffer window with the terminal UI.
" 4.  Once finished the callback will be invoked with the last stdout produced.
"
" Examples:
"
" " Fuzzy-find and edit files under the current directory.
" nnoremap <silent><leader>fz :call pick#NewScratchBuf()
"     \\|:.!ffind . '(' -type f -o -type l ')' -print<cr>
"     \\|:call pick#Pick({x -> execute('edit '. x)})<cr>
"
" " Fuzzy find :ls and edit the selected buffer.
" nnoremap <silent><leader>fx :call pick#NewScratchBuf()
"     \\|redir @m \| silent ls \| redir END
"     \\|:1put m
"     \\|:call pick#Pick({x -> execute('b '. matchstr(x, '[0-9]\+'))})<cr>

fu! pick#NewScratchBuf()
    below new
    setl buftype=nofile bufhidden=hide nobuflisted
endfu

fu! pick#Pick(Cb)
    let l:scrBuf = bufnr('%')
    let l:lastmsg = ""

    let l:tbuf = term_start('pick', {
        \ 'in_buf': bufnr('%'), 'in_io': 'buffer',
        \ 'curwin': 1, 'norestore': 1,
        \ 'out_cb': 'SaveMsg', 'term_finish': 'close', 'exit_cb': 'CallCb',
    \ })

    fu! CallCb(job, status) closure
        call term_wait(l:tbuf)

        " Nuke the scratch buffer.
        execute(l:scrBuf .'bw')
        if (a:status == 0)
            call a:Cb(trim(l:lastmsg))
        endif
    endfu

    fu! SaveMsg(chan, msg) closure
        " Ignore stdout while in an altscreen.
        if (! term_getaltscreen(l:tbuf))
            let l:lastmsg = a:msg
        endif
    endfu
endfu

" FIXME: how should you actually use tags?
" " Select a tag and jump to that.
" fu! pick#Tag()
"     let l:cmd_holder = ""

"     fu! GetData()
"         1put = taglist('.*')
"             \ ->map({i, x -> x.cmd .' --- '. x.filename})
"         1delete
"     endfu

"     fu! FmtRet(ret) closure
"         let l:ret = split(a:ret, ' --- ')
"         let l:cmd_holder = l:ret[0]
"         return l:ret[1]
"     endfu

"     fu! SwitchBuf(fname) closure
"         exe 'e '. a:fname
"         exe ':'. search(l:cmd_holder)
"     endfu

"     call pick#SwitchBuf('GetData', 'SwitchBuf', 'FmtRet')
" endfu
