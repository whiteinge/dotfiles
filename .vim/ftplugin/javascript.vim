let javaScript_fold=1
setl foldmethod=syntax

if exists("+omnifunc")
    setl omnifunc=javascriptcomplete#CompleteJS
endif
