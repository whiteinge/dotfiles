" MRU
" Massage and truncate the oldfiles list for an easy most-recently-used list.

fu! mru#MRU()
    let l:files = copy(v:oldfiles)
    let l:files = map(l:files, {idx, val -> {'idx': idx + 1, 'path': val}})

    let l:files = filter(l:files, {idx, val -> filereadable(expand(val['path']))
        \&& val['path'] !~ '__Tagbar__'
        \&& val['path'] !~ '__Gundo_'
        \&& val['path'] !~ '.git/'
        \&& val['path'] !~ 'vim/vim81/doc/'
        \&& val['path'] !~ '/dev/fd'
        \&& val['path'] !~ '/var/folders'
    \})

    let l:files = map(l:files, {idx, val -> val.idx ."\t". val.path})
    return join(l:files[:20], "\n") . "\n"
endfu
