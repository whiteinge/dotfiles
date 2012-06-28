setl textwidth=79

" FIXME: how to differentiate between rst2beamer and Sphinx?
" if !filereadable(expand(“%:p:h”).“/Makefile”)
"     setlocal makeprg=gcc\ –Wall\ –Wextra\ –o\ %<\ %
" endif

" \usecolortheme{wolverine}
" \usecolortheme{seahorse}
" \usecolortheme{seagull}
" \usecolortheme{dolphin}

" \ --theme=AnnArbor\
" \ --theme=Warsaw\
" \ --theme=Warsaw\

setl makeprg=rst2beamer.py\
    \ --theme=CambridgeUS\
    \ --codeblocks-use-pygments\
    \ --output-encoding-error-handler=backslashreplace\
    \ --overlaybullets=none\
    \ --output-encoding=UTF-8\
    \ %\
    \ /tmp/%<.tex

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

let b:ftskeleton="~/.vim/ftplugin/rst/skeleton/rst2beamer.rst"
