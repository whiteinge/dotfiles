if exists("+omnifunc")
    setl omnifunc=csscomplete#CompleteCSS
endif

setl formatprg=deno\ fmt\ --ext=css\ -
