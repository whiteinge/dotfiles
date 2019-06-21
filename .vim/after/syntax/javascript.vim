" Add simple jsx highlighting to the JavaScript syntax that ships with Vim.

if exists("b:current_syntax")
    unlet b:current_syntax
endif
syn include @XMLSyntax syntax/xml.vim

syn region jsxAttr
    \ start=+{+ end=+}+
    \ contained
    \ contains=@Spell,javaScriptEmbededExpr
    \ display

syn region jsxRegion
    \ start=+\%(<\|\w\)\@<!<\z([a-zA-Z_][a-zA-Z0-9:\-.]*\>[:,]\@!\)\([^>]*>(\)\@!+
    \ skip=+<!--\_.\{-}-->+
    \ end=+</\z1\_\s\{-}>+
    \ end=+/>+
    \ contains=@Spell,@XMLSyntax,jsxRegion,jsxAttr
    \ keepend
    \ extend

hi def link jsxRegion Special
