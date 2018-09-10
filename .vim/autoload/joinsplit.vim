" SplitItems Break out vals with a consistent delimiter on to separate lines
"
" Useful for reordering function parameters or list items or delimited text
" since Vim makes it easy to reorder lines. Once ordered, lines can be
" re-joined with the sister-function below.
"
" E.g., given the text:
"
"   def foo(bar, baz, qux, quux):
"       pass
"
" Use a text-object to select everything within the parenthesis:
" <leader>si(
" Choose ", " as the delimiter (the default), which results in:
"
"     def foo(
"   bar
"   baz
"   qux
"   quux
"   ):
"       pass
"
" Reorder the items as necessary then join using:
" <leader>ji(
" Choose ", " as the delimeter to join with (the default).
"
" FIXME: update this to use WrapOpfunc

fu! joinsplit#SplitItems(type, ...)
    let c = input("Split on what chars? ", ", ")
    normal! `[v`]x
    let @@ = substitute(@@, c, '\n', 'g')
    set paste
    exe "normal! i\<cr>\<esc>"
    pu! "
    set nopaste
endfu

fu! joinsplit#JoinItems(type, ...)
    let c = input("Join with what chars? ", ", ")
    normal! `[v']d
    let @@ = substitute(@@, '\n', c, 'g')
    set paste
    exe "normal! P\<esc>"
    set nopaste
endfu
