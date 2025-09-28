compiler tidy
setl formatprg=tidy\ --quiet\ yes

if exists("+omnifunc")
    setl omnifunc=htmlcomplete#CompleteTags
endif
