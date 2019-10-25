" Open a CLI fuzzy-finder and process the result
"
" The workflow for building a new mapping is:
" 1.  Create a new scratch buffer.
" 2.  Populate the buffer however is best for the data you want to filter. This
"     is done because it's easy to populate via shell commands, Vim variables,
"     or other Vim commands.
" 3.  Start the fuzzy-finder which will consume the buffer contents as stdin.
" 4.  The result will be returned as a string for use.
"
" Examples:
"
" " Fuzzy-find and edit files under the current directory.
" nnoremap <silent><leader>fz :call pick#NewScratchBuf()
"     \\|:.!ffind . '(' -type f -o -type l ')' -print<cr>
"     \\|:call pick#Pick() ->{x -> 'edit '. x}() ->execute()<cr>
"
" " Fuzzy find :ls and edit the selected buffer.
" nnoremap <silent><leader>fx :call pick#NewScratchBuf()
"     \\|redir @m \| silent ls \| redir END
"     \\|:1put m
"     \\|:call pick#Pick()
"         \ ->matchstr('[0-9]\+') ->{x -> 'b '. x}() ->execute()<cr>

fu! pick#NewScratchBuf()
    below new
    setl buftype=nofile bufhidden=hide nobuflisted
endfu

fu! pick#Pick()
    let l:scrBuf = bufnr('%')
    let l:lastmsg = ""

    let l:ret = system('fzy', l:scrBuf)
    call execute(l:scrBuf .'bw')
    redraw!

    return l:ret
endfu
