let php_sql_query = 1
let php_htmlInStrings = 1
let php_folding = 1

if exists("+omnifunc")
    setl omnifunc=phpcomplete#CompletePHP
endif

iab _profile
       \ $before = hrtime(true);
    \<cr>$after = hrtime(true);
    \<cr>$duration = ($after - $before) / 1000000;
    \<cr>print_r("Duration (ms): ". $duration .PHP_EOL);<cr>

" This can matter for old PHP using the closing ?> tag.
set nofixeol
