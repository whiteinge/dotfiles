let g:tex_fold_enabled=1
set fdm=syntax
set fdl=1

let g:tex_comment_nospell=1

" tagbar settings
let g:tagbar_type_tex = {
    \ 'ctagstype' : 'latex',
    \ 'kinds'     : [
        \ 's:sections',
        \ 'g:graphics:0:0',
        \ 'l:labels',
        \ 'r:refs:1:0',
        \ 'p:pagerefs:1:0'
    \ ],
    \ 'sort'    : 0,
\ }

" Use a skeleton template for creating invoices.
if bufname('%') =~? '.*invoice.*'
    let b:ftskeleton="~/.vim/ftplugin/tex/skeleton/invoice.tex"
endif
