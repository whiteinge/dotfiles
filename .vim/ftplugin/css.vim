if exists("+omnifunc")
    setl omnifunc=csscomplete#CompleteCSS
endif

fu! FormatCSS(buffer) abort
    return { 'command': 'deno fmt --ext=css -' }
endfu
exe ale#fix#registry#Add('deno', 'FormatCSS', ['css'], 'deno fmt for CSS')

let b:ale_fixers = ['deno', 'prettier']
