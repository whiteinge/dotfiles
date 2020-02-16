" Fold lines _outside_ of a given range
"
" Useful to focus on only a specific part of a file.

fu! foldaround#FoldAround(x, is_inline, begin, end)
    setl foldmethod=manual
    normal! zE

    let l:begin = a:begin - 1
    let l:end = a:end + 1

    if l:begin > 1
        exe printf('1,%sfold', l:begin)
    endif

    if l:end <= line('$')
        exe printf('%s,$fold', l:end)
    endif

    return -1
endfu
