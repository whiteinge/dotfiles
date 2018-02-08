let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:headings',
        \ 'l:links',
        \ 'i:images'
    \ ],
    \ "sort" : 0
\ }

" Use a skeleton template when editing a new file named 'presentation.md'
if bufname('%') == 'presentation.md'
    let b:ftskeleton="~/.vim/ftplugin/markdown/skeleton/remark.md"
endif

setl foldnestmax=1
let g:markdown_folding=1
let g:markdown_fenced_languages = ['html', 'python', 'sh', 'js=javascript', 'hs=haskell']
