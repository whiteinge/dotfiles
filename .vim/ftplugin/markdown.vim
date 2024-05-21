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
    let b:ftskeleton="~/.vim/ftplugin/markdown/skeleton/remark.md"
endif

" Disabled for now for perf reasons.
" let g:markdown_folding=1
let b:ale_enabled=0

setl foldnestmax=1

let g:markdown_fenced_languages = [
    \ 'html', 'python', 'ruby', 'sh', 'c', 'cpp', 'dot', 'diff', 'sql',
    \'js=javascript', 'ts=typescript', 'hs=haskell', 'math=tex']

setl textwidth=79
