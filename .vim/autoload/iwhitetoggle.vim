" Toggle respecting/ignoring whitespace differences.
" http://vim.wikia.com/wiki/Ignore_white_space_in_vimdiff

fu! iwhitetoggle#IwhiteToggle()
    if &diffopt =~ 'iwhite'
        set diffopt-=iwhite
    else
        set diffopt+=iwhite
    endif
endfu
