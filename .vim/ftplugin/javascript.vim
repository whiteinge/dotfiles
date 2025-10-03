setl foldmethod=indent
setl foldnestmax=1

if exists("+omnifunc")
    setl omnifunc=javascriptcomplete#CompleteJS
endif

setl keywordprg=sh\ -c\ 'xdg-open\ https://devdocs.io/\\#q=\$1\ '\ --

let b:checkformat='file://%f: line %l\, col %c - %m'
let b:checkprg='_deno-lint %'
setl formatprg=deno\ fmt\ -

" (Req's my split/join plugin & mappings.)
let _sort_es6_imports = 'f{\js,i{vi{!sort\jj,i{kJJ'

let _namespace_action = 'f:wa=expand("%:t:r")/gui'
let _namespace_all_actions = 'vi{:QQ g:_namespace_action'

" (Req's my Caser and surround mappings.)
let _css_to_js = '^\wct:ww\s''$hxpr,'
let _js_to_css = 'w\wkwf''xf''xr;'

let g:tagbar_type_javascript = {
    \ 'ctagstype': 'javascript',
    \ 'kinds' : [
        \ 'f:functions',
        \ 'm:methods',
        \ 'C:constants:0:0',
        \ 'c:classes',
        \ 'v:global variables:0:0',
        \ 'g:generators:0:0',
        \ 'p:properties:0:0',
        \ '?:unknown',
    \ ],
\ }

let g:tagbar_type_javascriptreact = g:tagbar_type_javascript
