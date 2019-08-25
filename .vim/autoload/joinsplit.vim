" Split items in a text block into separate lines using a specified delimeter.
" Join lines in a text block back together using a specified delimiter.
"
" Useful for reordering function parameters or list items or delimited text.
" Split items onto separate lines, order them however you'd like using normal
" Vim-fu, then re-join the lines. E.g.:
"
" 1.    Given the text:
"
"       def foo(bar, baz, qux, quux): pass
"
" 2.    Use a text-object to select everything within the parenthesis. Choose
"       ", " as the delimiter (the default), which results in:
"
"       def foo(
"       bar
"       baz
"       qux
"       quux
"       ): pass
"
" 3.    Reorder the items as necessary. (gv is useful to reselect the previous
"       selection. Move lines manually or re-select use !sort.)
" 4.    Finally join again using the same text-object. Choose ", " as the
"       delimeter to join with (the default).

fu! joinsplit#SplitItems(text, is_inline, char)
    return a:text
        \ ->{x -> a:is_inline ? split(x, a:char) : split(x, "\n")}()
        \ ->map({i, x -> trim(x, " \r\n\t". a:char)})
        \ ->join("\n")
        \ ->{x -> a:is_inline ? x ."\n" : x}()
endfu

fu! joinsplit#JoinItems(text, is_inline, char)
    return a:text
        \ ->split("\n")
        \ ->join(a:char)
endfu
