" Use two-spaces for indentation
set softtabstop=2
set shiftwidth=2

let php_sql_query = 1
let php_htmlInStrings = 1
let php_folding = 1

if exists("+omnifunc")
    setl omnifunc=phpcomplete#CompletePHP
endif

if has("autocmd")
    au BufWritePost *.php silent! !ctags -R %:p:h
endif

iab die die("<div class='debug'>".__CLASS__." ".__FUNCTION__."  ".__FILE__." [".__LINE__."]<pre>".print_r(, true)."</pre><div>");  // JBS DEBUG
