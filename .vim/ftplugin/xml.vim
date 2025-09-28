setl formatprg='xmlstarlet\ fo\ -'

if exists("+omnifunc")
    setl omnifunc=xmlcomplete#CompleteXML
endif
