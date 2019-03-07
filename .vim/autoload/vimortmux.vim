" Stolen from the excellent vim-tmux-navigator; my needs are more simple

fu! vimortmux#VimOrTmuxNav(direction)
    let l:nr = winnr()
    execute 'wincmd '. a:direction

    if (nr == winnr())
        let l:cmd = 'tmux select-pane -'. tr(a:direction, 'hjkl', 'LDUR')
        return system(l:cmd)
    endif
endfu
