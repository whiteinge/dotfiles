" Mimic git add --patch but using Vimdiff to move and stage hunks.
" Concept borrowed from the excellent Fugitive.
" Call stagediff#StageDiff to open a new tab containing the diff.
"
" Move changes left to stage them.

fu! s:RepoRelPath()
    let l:prefix = trim(system('git rev-parse --show-prefix'))
    if v:shell_error
        return ''
    endif
    return l:prefix . expand('%:.')
endfu

fu! s:WriteToIndex(fname, repopath)
    let l:safe = shellescape(a:fname)
    let l:safe_repo = shellescape(a:repopath)
    try
        let l:mode = split(system('git ls-files --stage '. l:safe), ' ')[0]
    catch
        let l:mode = '100644'
    endtry

    exe 'write !git hash-object --stdin -w
        \ | xargs -I@ git update-index --add
        \ --cacheinfo '. l:mode .',@,'. l:safe_repo
    if v:shell_error
        echohl ErrorMsg
            \ | echon "Stage failed (exit ". v:shell_error .")"
            \ | echohl None
        return
    endif
    set nomodified
endfu

fu! stagediff#StageDiff()
    let l:fname = fnamemodify(expand('%'), ':~:.')
    let l:repopath = s:RepoRelPath()
    let l:safe = shellescape(l:fname)
    let l:safe_repo = shellescape(l:repopath)
    let l:ft = &ft

    if (len(system('git ls-files --unmerged '. l:safe)))
        echohl WarningMsg
            \ | echon "Please resolve conflicts first."
            \ | echohl None
        return 1
    endif

    tabe %
    diffthis
    vnew

    call system('git ls-files --error-unmatch '. l:safe)
    if (!v:shell_error)
        silent exe ':r !git show :'. l:safe_repo
        1delete
    endif

    set nomodified
    let &ft = l:ft
    diffthis

    setl buftype=acwrite bufhidden=delete nobuflisted
    let b:stagediff_fname = l:fname
    let b:stagediff_repopath = l:repopath
    au BufWriteCmd <buffer>
        \ call <SID>WriteToIndex(b:stagediff_fname, b:stagediff_repopath)
    exe 'file staging://'. l:fname

    redraw
    echohl WarningMsg
        \ | echon "Move changes leftward then write file to stage."
        \ | echohl None
endfu
