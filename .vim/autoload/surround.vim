" Surround text with characters
"
" Surround('foo', 1, '<')   // => <foo>

fu! surround#Surround(text, is_inline, surround_char, ...)
    let l:common_pairs = {
        \'{': '}', '}': '{',
        \'(': ')', ')': '(',
        \'<': '>', '>': '<',
    \}

    let l:open = a:surround_char
    let l:close = get(l:common_pairs, l:open, l:open)

    if !a:is_inline
        let l:open = l:open ."\n"
    endif

    let l:ret = substitute(a:text, '^', l:open, "")
    let l:ret = substitute(l:ret, '$', l:close, "")

    return l:ret
endfu
