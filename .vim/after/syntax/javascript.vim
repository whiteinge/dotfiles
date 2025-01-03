if exists('main_syntax')
    " Other syntax files (Markdown, PHP, rST) source the entire HTML syntax
    " file, which can then include this file which sources the HTML file again.
    " This leads to weird missing variable errors.
    finish
endif

let s:current_syntax_save = b:current_syntax

" Add (very) simple JSX highlighting.
runtime! syntax/xml.vim
let b:current_syntax = s:current_syntax_save

" Add support for html tagged template literals.
let g:main_syntax = 'java' " Avoid circular HTML/JavaScript syntax include.
syn include @htmlSyntax syntax/html.vim
let b:current_syntax = s:current_syntax_save

syn region htmlTaggedTemplate
    \ start="html`" end="`"
    \ matchgroup=Type
    \ skip=+\\\\\|\\`+
    \ contains=@htmlSyntax,javaScriptEmbedWithHtmlTemplate

syn region javaScriptEmbedWithHtmlTemplate
    \ start=+${+ end=+}+
    \ contains=@javaScriptEmbededExpr,htmlTaggedTemplate

" Add support for css tagged template literals.
syn include @htmlCss syntax/css.vim
let b:current_syntax = s:current_syntax_save

syn region cssTaggedTemplate
    \ start="css`" end="`"
    \ matchgroup=Type
    \ skip=+\\\\\|\\`+
    \ contains=@htmlCss,javaScriptEmbedWithCssTemplate

syn region javaScriptEmbedWithCssTemplate
    \ start=+${+ end=+}+
    \ contains=@javaScriptEmbededExpr,cssTaggedTemplate
