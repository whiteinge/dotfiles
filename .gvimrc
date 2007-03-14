" Ok-ish gvimrc 'cause sometimes you get sick of a terminal's shitty color support
" Author: Seth House <seth@eseth.com>
" $Id$

color desert
hi LineNr guibg=#222222
hi TabLine gui=none

set guioptions=acgit            "go:    A minimal (console-like) set of GUI options

" The following two lines maximize the gVim window under X11 and on OS X
set lines=999
set columns=999

if has ("macunix")
    au GUIEnter * winpos 0 40
    set nomacatsui anti enc=utf-8 gfn=Monaco:h11
endif

if has ("win32")
    au GUIEnter * simalt ~x
    set guifont=fixed,vt100:h10,Lucida_Console:h8
    set shell=C:/cygwin/bin/zsh
    set shellcmdflag=--login\ -c
    set shellxquote=\"
endif
