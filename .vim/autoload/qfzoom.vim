" Open the contents of the current quickfix entry in a popup window. Works with
" multi-line quickfix entries.
fu! qfzoom#Qfzoom()
    let l:curIdx = getqflist({'idx': 0}).idx - 1
    let l:qflist = getqflist()
    let l:textarr = [l:qflist[l:curIdx].text]

    let l:i = l:curIdx + 1
    while l:i < len(l:qflist)
        if l:qflist[l:i].valid == 1
            break
        endif

        let l:textarr += [l:qflist[l:i].text]
        let l:i += 1
    endwhile

    call popup_close(winnr() ->getwinvar('popupid', -1))
    let w:popupid = popup_create(l:textarr, {
        \'title': " Quickfix #". l:curIdx ." ",
        \'padding': [],
        \'border': [],
        \'highlight': 'hl-Normal',
        \'moved': 'any',
    \ })

    " FIXME: This is specifically useful for my bin/diff-to-quickfix script,
    " but I don't want to hard-code the ft here...
    call setbufvar(winbufnr(w:popupid), '&filetype', 'diff')
endfu
