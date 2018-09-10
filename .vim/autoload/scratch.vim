" Make the current buffer a scratch buffer

function! scratch#Scratch()
    setl buftype=nofile bufhidden=delete nobuflisted
    Warn "This file is now a scratch file!"
endfunction
