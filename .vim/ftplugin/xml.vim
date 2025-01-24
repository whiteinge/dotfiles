setl formatprg='xmlstarlet\ fo\ -'

if exists("+omnifunc")
    setl omnifunc=xmlcomplete#CompleteXML
endif

fu! FormatXML(buffer) abort
    return { 'command': 'xmlstarlet fo -' }
endfu
exe ale#fix#registry#Add('xmlstarfo', 'FormatXML', ['xml', 'svg'], 'xmlstarlet formatting for XML')

let b:ale_fixers = ['xmlstarfo']
