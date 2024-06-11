if exists('main_syntax')
    if g:main_syntax == 'markdown'
        " The Markdown syntax file sources the entire HTML syntax file, and
        " then including this as a JavaScript fenced language tries to source
        " the HTML file again below. (At least I think that's what's
        " happening.) This leads to weird missing variable errors. I tried to
        " troubleshoot but gave up.
        finish
    endif
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
