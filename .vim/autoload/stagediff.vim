" Mimic git add --patch but using Vimdiff to move and stage hunks.
" Concept borrowed from the excellent Fugitive.
" Call stagediff#StageDiff to open a new tab containing the diff.

fu! s:WriteToIndex(fname)
    try
        let l:mode = split(system('git ls-files --stage '. a:fname), ' ')[0]
    catch
        let l:mode = '100644'
    endtry

    let l:ret = execute('write !git hash-object --stdin -w
        \ | xargs -I@ git update-index --add
        \ --cacheinfo '. l:mode .',@,'. a:fname)
    set nomodified
endfu

fu! stagediff#StageDiff()
    let s:fname = fnamemodify(expand('%'), ':~:.')
    let l:ft = &ft

    if (len(system('git ls-files --unmerged '. s:fname)))
        echohl WarningMsg
            \ | echon "Please resolve conflicts first."
            \ | echohl None
        return 1
    endif

    tabe %
    diffthis
    vnew

    call system('git ls-files --error-unmatch '. s:fname)
    if (!v:shell_error)
        silent exe ':r !git show :'. s:fname
        1delete
    endif

    set nomodified
    let &ft = l:ft
    diffthis

    setl buftype=acwrite bufhidden=delete nobuflisted
    au BufWriteCmd <buffer> call <SID>WriteToIndex(s:fname)
    exe 'file _staging_'. s:fname

    redraw
    echohl WarningMsg
        \ | echon "Move changes leftward then write file to stage."
        \ | echohl None
endfu
