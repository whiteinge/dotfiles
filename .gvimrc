" Ok-ish gvimrc 'cause sometimes assholes make you use GUIs
" Author: Seth House <seth@eseth.com>

color desert
hi LineNr guibg=#222222
hi TabLine gui=none

set guioptions=acgit            "go:    A minimal (console-like) set of GUI options

if has ("macunix") " pretty anti-aliased font
    au GUIEnter * winpos 0 40
    set nomacatsui anti enc=utf-8 gfn=Monaco:h11

    " Maximize the window (stupid workaround, don't think there's a better way)
    set lines=999
    set columns=999
endif

if has ("win32")
    " Maximize the window
    au GUIEnter * simalt ~x

    set guifont=fixed,vt100:h10,Lucida_Console:h8
    set shell=C:/cygwin/bin/zsh
    set shellcmdflag=--login\ -c
    set shellxquote=\"
endif


let g:Powerline_symbols = 'fancy'
