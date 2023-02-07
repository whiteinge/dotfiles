let php_sql_query = 1
let php_htmlInStrings = 1
let php_folding = 1

if exists("+omnifunc")
    setl omnifunc=phpcomplete#CompletePHP
endif
