let b:checkformat='xmlstarlet fo -'

if exists("+omnifunc")
    setl omnifunc=xmlcomplete#CompleteXML
endif
