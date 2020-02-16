" Helper function for making opfunc operators
"
" Abstract the boilerplate around opfunc so we can write simple functions that
" take an input, modify it, and return the replacement text.
"
" Usage:
"
" fu! MyFunc(text, is_inline, foo, bar) | return 'sometext' | endfu
" nmap <expr> <leader>mf opfuncwrapper#WrapOpfunc('MyFunc', 1, 'foo', 'bar'))
" vmap <silent> <leader>mf :<C-U>call opfuncwrapper#WrapOpfunc(
"       \'MyFunc', 0, 'foo', 'bar')<cr>
"
" Return -1 to avoid changing the file.

fu! opfuncwrapper#WrapOpfunc(fnStr, is_map, ...)
    let l:Fn = function(a:fnStr)
    let l:args = a:000

    fu! OpfuncWrapper(type, ...) closure abort
        let l:reg_backup = @@
        let l:sel_backup = &selection
        let &selection = "inclusive"
        " -- Backup ^^

        let l:begin = line("'[")
        let l:end = line("']")
        if a:0  " Invoked from Visual mode, use '< and '> marks.
            let l:is_inline = 0
            silent exe "normal! `<" . a:type . "`>y"
            let l:begin = line("'<")
            let l:end = line("'>")
        elseif a:type == 'line' " Line
            let l:is_inline = 0
            silent exe "normal! '[V']y"
        elseif a:type == 'block' " Block
            let l:is_inline = 0
            silent exe "normal! `[\<C-V>`]y"
        else " inline
            let l:is_inline = 1
            silent exe "normal! `[v`]y"
        endif

        " Call fn on the yank register, reselect, then paste new results.
        let @@ = call(l:Fn, [@@, l:is_inline] + l:args + [l:begin, l:end])
        if @@ != -1
            normal! gvp
        endif

        " -- Restore vv
        let @@ = l:reg_backup
        let &selection = l:sel_backup
    endfu

    " opfunc can't see funcrefs so we can't return the wrapper and call it
    " directly from a mapping. Instead we have to know how it was called here
    " then either return an <expr> or call our wrapper indirectly. Wish list:
    " let g:MyOpfunc = WrapOpfunc('Myfunc')
    " nmap <silent> <leader>mf :set opfunc=MyOpfunc<cr>g@
    if a:is_map
        set opfunc=OpfuncWrapper
        return 'g@'
    else
        call OpfuncWrapper(visualmode(), 1)
    endif
endfu
