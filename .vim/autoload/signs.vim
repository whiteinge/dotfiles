call sign_define([
    \ {'name' : 'GitAdd', 'text' : '+', 'texthl': 'Question'},
    \ {'name' : 'GitDel', 'text' : '-', 'texthl': 'WarningMsg'},
    \ {'name' : 'GitMod', 'text' : '=', 'texthl': 'Normal'},
    \ {'name' : 'QfErr', 'text' : 'E', 'texthl': 'WarningMsg'},
    \ {'name' : 'QfWarn', 'text' : 'W', 'texthl': 'WarningMsg'},
    \ {'name' : 'QfGen', 'text' : '>', 'texthl': 'Normal'},
    \ {'name' : 'LlErr', 'text' : 'E', 'texthl': 'WarningMsg'},
    \ {'name' : 'LlWarn', 'text' : 'W', 'texthl': 'WarningMsg'},
    \ {'name' : 'LlGen', 'text' : '>', 'texthl': 'Normal'},
\ ])

" Return modified/deleted lines from Git.
fu! signs#GitChanges()
    let l:curbuf = bufnr('%')
    let l:curfile = expand('%')
    let l:group = 'signs#git'

    call sign_unplace(l:group, {'buffer' : l:curbuf})

    let l:lines_changed = systemlist('git diff -U0 -- '.
            \ shellescape(l:curfile) .' 2>/dev/null '
            \ .'| diff-to-line-numbers 2>/dev/null | tail -n +2 | cut -f1')
        \ ->map({i, x -> split(x, ' ')})
    let l:g_items = {}
    for [i_num, i_type] in l:lines_changed
        if has_key(l:g_items, i_num)
            let l:g_items[i_num] = 'GitMod'
        else
            if i_type == '+'
                let l:g_items[i_num] = 'GitAdd'
            else
                let l:g_items[i_num] = 'GitDel'
            endif
        endif
    endfor

    let l:signs_array = l:g_items
        \ ->items()
        \ ->map({i, xs -> {
            \ 'buffer': l:curbuf,
            \ 'group': l:group,
            \ 'lnum': xs[0],
            \ 'name': xs[1],
        \ }})

    call sign_placelist(l:signs_array)
endfu

" Add any quickfix entries for the current file.
fu! signs#Qflist()
    let l:curbuf = bufnr('%')
    let l:group = 'signs#qf'

    call sign_unplace(l:group)

    let l:signs_array = getqflist()
        \ ->filter({i, x -> bufexists(x.bufnr) && x.lnum != 0 && x.bufnr != 0})
        \ ->map({i, x -> {
            \ 'buffer': x.bufnr,
            \ 'group': l:group,
            \ 'lnum': x.lnum,
            \ 'name': get({'E': 'QfErr', 'W': 'QfWarn'}, x.type, 'QfGen'),
        \ }})

    call sign_placelist(l:signs_array)
endfu

" Add any location list entries
fu! signs#Loclist(...)
    let l:bufnr = bufnr()
    let l:group = 'signs#loclist'

    call sign_unplace(l:group)

    call getloclist(0)
        \ ->map({i, x -> {
            \ 'buffer': l:bufnr,
            \ 'group': l:group,
            \ 'lnum': x.lnum,
            \ 'name': get({'E': 'LlErr', 'W': 'LlWarn'}, x.type, 'LlGen'),
        \ }})
        \ ->sign_placelist()
endfu

fu! signs#Move(direction)
    let l:curline = getcurpos() ->get(1)
    let l:lnums = bufname('%')
        \ ->sign_getplaced({'group': '*'})
        \ ->get(0) ->get('signs')
        \ ->map({i, x -> x.lnum})
        \ ->sort('n') ->uniq()

    if a:direction == 1
        return l:lnums ->util#Find({x -> x > l:curline})
    elseif a:direction == 0
        return l:lnums ->reverse() ->util#Find({x -> x < l:curline})
endfu
