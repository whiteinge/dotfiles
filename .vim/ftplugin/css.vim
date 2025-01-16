if exists("+omnifunc")
    setl omnifunc=csscomplete#CompleteCSS
endif

fu! FormatCSS(buffer) abort
    return { 'command': 'deno fmt --ext=css -' }
endfu
exe ale#fix#registry#Add('denocss', 'FormatCSS', ['css'], 'deno fmt for CSS')

let b:ale_fixers = ['denocss', 'prettier']
