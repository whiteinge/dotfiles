setl textwidth=79

" Decided whether to build Beamer presentation or build Sphinx documentation
if bufname('%') == 'presentation.rst'
    setlocal makeprg=../beamer.py\ %\ /tmp/presentation.pdf
else
    setl makeprg=make\ html\ SPHINXOPTS=\"-q\"\ SPHINXBUILD=$HOME/var/cache/venvs/sphinx/bin/sphinx-build
endif

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
if bufname('%') =~? 'presentation\.rst$'
    let b:ftskeleton="~/.vim/ftplugin/rst/skeleton/rst2beamer.rst"
endif
