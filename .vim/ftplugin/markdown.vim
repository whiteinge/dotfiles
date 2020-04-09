let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:headings',
        \ 'l:links:1',
        \ 'i:images:1'
    \ ],
    \ "sort" : 0
\ }

" Use a skeleton template when editing a new file named 'presentation.md'
if bufname('%') =~? 'presentation\.md$'
    let b:ftskeleton="~/.vim/ftplugin/markdown/skeleton/remark.md"
endif

" Disabled for now for perf reasons.
" let g:markdown_folding=1
let b:ale_enabled=0

setl foldnestmax=1

let g:markdown_fenced_languages = ['html', 'python', 'ruby', 'sh',
    \'js=javascript', 'ts=typescript', 'hs=haskell', 'math=tex']

setl textwidth=79
