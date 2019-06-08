compiler xmllint
setl formatprg='xmllint\ --format\ --recover\ -'

if exists("+omnifunc")
    setl omnifunc=xmlcomplete#CompleteXML
endif
