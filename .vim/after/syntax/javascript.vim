" Add simple jsx highlighting to the JavaScript syntax that ships with Vim.

if exists("b:current_syntax")
    unlet b:current_syntax
endif

" TODO: what happens if I load XML first and JavaScript second?
runtime! syntax/xml.vim
hi def link xmlError NONE

syn region jsxString
    \ start=+{+ms=s+2 end=+}+me=s-2
    \ contained
    \ containedin=xmlTag
    \ contains=TOP
    \ contains=@Spell,@javaScriptEmbededExpr,javaScriptBraces,javaScriptComment,javaScriptLineComment,xmlTag
