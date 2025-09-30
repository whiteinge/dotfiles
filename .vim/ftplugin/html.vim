" Many other filetypes will source this one.
if &filetype != 'html'
    finish
endif

compiler tidy
setl formatprg=tidy\ --quiet\ yes

if exists("+omnifunc")
    setl omnifunc=htmlcomplete#CompleteTags
endif
