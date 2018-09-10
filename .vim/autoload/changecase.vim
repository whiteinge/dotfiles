fu! changecase#ChangeCase(text, is_inline, conversion)
    " https://github.com/chiedo/vim-case-convert
    if a:conversion == "CamelToHyphen"
        let search_for = '\(\<\u\l\+\|\l\+\)\(\u\)'
        let replace_with = '\l\1-\l\2'
    elseif a:conversion == "CamelToSnake"
        let search_for = '\(\<\u\l\+\|\l\+\)\(\u\)'
        let replace_with = '\l\1_\l\2'
    elseif a:conversion == "HyphenToCamel"
        let search_for = '\%(\%(\k\+\)\)\@<=-\(\k\)'
        let replace_with = '\u\1'
    elseif a:conversion == "HyphenToSnake"
        let search_for = '\%(\%(\k\+\)\)\@<=-\(\k\)'
        let replace_with = '\_\1'
    elseif a:conversion == "SnakeToCamel"
        let search_for = '\%(\%(\k\+\)\)\@<=_\(\k\)'
        let replace_with = '\u\1'
    elseif a:conversion == "SnakeToHyphen"
        let search_for = '\%(\%(\k\+\)\)\@<=_\(\k\)'
        let replace_with = '\-\1'
    endif

    return substitute(a:text, search_for, replace_with, "")
endfu
