if exists("b:current_syntax")
    unlet b:current_syntax
endif

" Add (very) simple JSX highlighting.
runtime! syntax/xml.vim

" Add support for html tagged template literals.
let main_syntax = 'java' " avoid circular HTML/JavaScript syntax include
syn include @htmlSyntax syntax/html.vim

syn region htmlTaggedTemplate
    \ start="html`" end="`"
    \ matchgroup=Type
    \ skip=+\\\\\|\\`+
    \ contains=@htmlSyntax,javaScriptEmbedWithHtmlTemplate

syn region javaScriptEmbedWithHtmlTemplate
    \ start=+${+ end=+}+
    \ contains=@javaScriptEmbededExpr,htmlTaggedTemplate
