let g:tagbar_type_markdown = {
  \ 'ctagstype': 'markdown',
  \ 'kinds': [
    \ 'c:chapter:0:1',
    \ 's:section:0:1',
    \ 'S:subsection:0:1',
    \ 't:subsubsection:0:1',
    \ 'T:l4subsection:0:1',
    \ 'u:l5subsection:0:1',
  \ ],
  \ 'sro': '""',
  \ 'kind2scope': {
    \ 'c' : 'chapter',
    \ 's' : 'section',
    \ 'S' : 'subsection',
    \ 't' : 'subsubsection',
    \ 'T' : 'l4subsection',
  \ },
  \ 'scope2kind': {
    \ 'chapter': 'c',
    \ 'section': 's',
    \ 'subsection': 'S',
    \ 'subsubsection': 't',
    \ 'l4subsection': 'T',
  \ },
\ }

" Use a skeleton template when editing a new file named 'presentation.md'
if bufname('%') =~? 'presentation\.md$'
    let b:ftskeleton="~/.vim/ftplugin/markdown/skeleton/pandoc.md"
endif

let g:markdown_fenced_languages = [
    \ 'html', 'python', 'ruby', 'sh', 'c', 'cpp', 'dot', 'diff', 'sql',
    \'js=javascript', 'ts=typescript', 'hs=haskell', 'math=tex']

" :Backlinks — quickfix list of notes that link to the current file.
" (Tagbar shows this file's outline; backlinks are cross-file, so they go to the
" quickfix list instead. .backlinks.sh lives at the repo root.)
command! -buffer -bar Backlinks call s:Backlinks()
function! s:Backlinks() abort
    let l:root = trim(system('git -C ' . shellescape(expand('%:p:h')) . ' rev-parse --show-toplevel'))
    if v:shell_error
        echohl ErrorMsg | echom 'Backlinks: not inside a git repo' | echohl None | return
    endif
    let l:out = systemlist(shellescape(l:root . '/.backlinks.sh') . ' ' . shellescape(expand('%:p')))
    if empty(l:out)
        echom 'Backlinks: none for ' . expand('%:t')
        return
    endif
    let l:save = &errorformat
    set errorformat=%f:%l:%m
    cgetexpr l:out
    let &errorformat = l:save
    copen
endfunction
