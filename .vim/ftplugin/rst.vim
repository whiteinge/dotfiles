setl textwidth=79

" FIXME: how to differentiate between rst2beamer and Sphinx?
" if !filereadable(expand(“%:p:h”).“/Makefile”)
"     setlocal makeprg=gcc\ –Wall\ –Wextra\ –o\ %<\ %
" endif

" tagbar settings
let g:tagbar_type_rst = {
    \ 'ctagsbin' : 'rst2ctags',
    \ 'ctagsargs' : '--taglist',
    \ 'kinds' : [
        \ 's:Sections',
        \ 'i:Images',
    \ ],
\ }

" More easily make headings in rST
noremap <Leader>h <Esc>:norm yypVr

" Use a skeleton template when editing a new file named 'presentation.rst'
if bufname('%') == 'presentation.rst'
    let b:ftskeleton="~/.vim/ftplugin/rst/skeleton/rst2beamer.rst"
endif
