" utf-8 should be set if not already done globally
setl fileencoding=utf-8
setl matchpairs+=<:>

" Treat lists, indented text and tables as comment lines and continue with the
" same formatting in the next line (i.e. insert the comment leader) when hitting
" <CR> or using "o".
setl comments=n:#,n:*,n:\:,s:{\|,m:\|,ex:\|}
setl formatoptions+=roq

if exists("+omnifunc")
    setl omnifunc=htmlcomplete#CompleteTags
endif

" match HTML tags (taken directly from $VIM/ftplugin/html.vim)
if exists("loaded_matchit")
    let b:match_ignorecase=0
    let b:match_skip = 's:Comment'
    let b:match_words = '<:>,' .
    \ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
    \ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
    \ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'
endif

" Other useful mappings
" Insert a matching = automatically while starting a new header.
inoremap <buffer> <silent> = <C-R>=(getline('.')==''\|\|getline('.')=~'^=\+$')?"==\<Lt>Left>":"="<CR>

" Enable folding based on ==sections==
" setlocal foldexpr=getline(v:lnum)=~'^\\(=\\+\\)[^=]\\+\\1\\(\\s*<!--.*-->\\)\\=\\s*$'?\">\".(len(matchstr(getline(v:lnum),'^=\\+'))-1):\"=\"
" setlocal fdm=expr

" tagbar settings
let g:tagbar_type_mediawiki = {
    \ 'ctagstype' : 'mediawiki',
    \ 'kinds' : [
        \ 'h:Headings',
    \ ],
\ }
