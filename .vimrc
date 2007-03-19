" Best Goddamn vimrc in the whole world.
" Author: Seth House <seth@eseth.com>
" Release: 1.1.1
" Version: $LastChangedRevision$
" Modified: $LastChangedDate$
" Revamped for Vim 7 - will output a few non-critical errors for old versions.
" For more information type :help followed by the command.

set nocompatible                "cp:    turns off strct vi compatibility

" Search {{{

set incsearch                   "is:    automatically begins searching as you type
set ignorecase                  "ic:    ignores case when pattern matching
set smartcase                   "scs:   ignores ignorecase when pattern contains uppercase characters
set hlsearch                    "hls:   highlights search results
" Use ctrl-n to unhighlight search results in normal mode:
nmap <silent> <C-N> :silent noh<CR>

" }}}
" Line Wrap {{{

set backspace=indent,eol,start  "bs:    allows you to backspace over the listed character types
set linebreak                   "lbr:   causes vim to not wrap text in the middle of a word
set wrap                        "wrap:  wraps lines by default
" Toggle line wrapping in normal mode:
nmap <silent> <C-P> :set nowrap!<CR>:set nowrap?<CR>

" }}}
" Editing {{{

syntax on                       "syn:   syntax highlighting
set showmatch                   "sm:    flashes matching brackets or parentheses

" Searches the current directory as well as subdirectories when using certain commands
set path=.,**

set cindent                     "cin:   enables the second-most configurable indentation (see :help C-indenting).
set cinoptions=l1,c4,(s,U1,w1,m1,j1
set cinwords=if,elif,else,for,while,try,except,finally,def,class

set expandtab                   "et:    uses spaces instead of tab characters
set smarttab                    "sta:   helps with backspacing because of expandtab
set tabstop=4                   "ts:    number of spaces that a tab counts for
set shiftwidth=4                "sw:    number of spaces to use for autoindent
set shiftround                  "sr:    rounds indent to a multiple of shiftwidth

set listchars=tab:>-,eol:$      "lcs:   makes finding tabs easier during :set list
set lazyredraw                  "lz:    will not redraw the screen while running macros (goes faster)
set pastetoggle=<F7>            "pt:    useful so auto-indenting doesn't mess up code when pasting
" Toggle spell-checking with F8
map <silent> <F8> :set nospell!<CR>:set nospell?<CR>

" }}}
" Folding (spacebar toggles) {{{
" Spacebar toggles a fold, zi toggles all folding, zM closes all folds

noremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

set foldmethod=marker           "fdm:   looks for patterns of triple-braces in a file
set foldcolumn=4                "fdc:   creates a small left-hand gutter for displaying fold info

" }}}
" Menu completion {{{

set wildmenu                    "wmnu:  enhanced ex command completion
set wildmode=longest:full,list:full  "wim:   helps wildmenu auto-completion

" }}}
" Window Layout {{{

set number                      "nu:    numbers lines
set showmode                    "smd:   shows current vi mode in lower left
set cursorline                  "cul:   highlights the current line
set showcmd                     "sc:    shows typed commands
set cmdheight=2                 "ch:    make a little more room for error messages
set scrolloff=2                 "so:    places a couple lines between the current line and the screen edge
set sidescrolloff=2             "siso:  places a couple lines between the current column and the screen edge
set laststatus=2                "ls:    makes the status bar always visible
set ttyfast                     "tf:    improves redrawing for newer computers
set viminfo='500,f1,:100,/100   "vi:    For a nice, huuuuuge viminfo file

" }}}
" Multi-buffer editing {{{

set switchbuf=useopen           "swb:   Jumps to first window or tab that contains specified buffer instead of duplicating an open window
set showtabline=1               "stal:  Display the tabbar if there are multiple tabs. Use :tab ball or invoke Vim with -p
set hidden                      "hid:   allows opening a new buffer in place of an existing one without first saving the existing one

" I'm not sure why Vim displays one line by default when 'maximizing' a split window with ctrl-_
set winminheight=0              "wmh:   the minimal height of any non-current window
set winminwidth=0               "wmw:   the minimal width of any non-current window

" Earlier Vims did not support tabs. Below is a vertical-tab-like cludge. Use :ball or invoke Vim with -o
" http://www.vim.org/tips/tip.php?tip_id=173
if version < 700
    " ctrl-j,k will move up or down between split buffers and maximize the current buffer
    nmap <C-J> <C-W>j<C-W>_
    nmap <C-K> <C-W>k<C-W>_
endif

" }}}
" Color {{{
"     All coloring options are for the non-GUI Vim (see :help cterm-colors).
"     These are not very portable and could break on some systems.
"     TODO: ctermfg=8 displays as black if only using 8-colors, but as a nice grey under 16. need more testing on Linux systems.

set t_Co=16                     "   tells Vim to use 16 colors (appears to work on 8-color terms like xterm-color)

" The default fold color is too bright and looks too much like the statusline
hi Folded cterm=bold ctermfg=8 ctermbg=0

" I love the new CursorLine, but terminal underlining kicks legibility in the nuts.
" So what to do? Bold is (extremely) subtle, but it's better than nothing.
hi CursorLine cterm=bold

" Vim is picking up a white bg from somewhere which is annoying...
hi Visual ctermbg=none

" Default StatusLine highlighting
" hi StatusLine term=bold,reverse cterm=bold,reverse
hi StatusLine cterm=bold,underline
hi StatusLineNC cterm=bold,underline ctermfg=8

hi User1 term=bold,reverse cterm=bold,underline ctermfg=4
hi User2 term=bold,reverse cterm=bold,underline ctermfg=1
hi User3 term=bold,reverse cterm=bold,underline ctermfg=5
hi User4 term=bold,reverse cterm=bold,underline ctermfg=8
hi User5 term=bold,reverse cterm=bold,underline ctermfg=6
hi User6 term=bold,reverse cterm=bold,underline ctermfg=2
hi User7 term=bold,reverse cterm=bold ctermfg=2
hi User8 term=bold,reverse cterm=bold,underline ctermfg=3

" A nice, minimalistic tabline
hi TabLine cterm=underline ctermfg=8 ctermbg=0
hi TabLineSel cterm=none ctermfg=0 ctermbg=7
hi TabLineFill cterm=none ctermbg=0

" The default foldcolumn is briiiight.
hi FoldColumn cterm=bold ctermfg=8 ctermbg=0

" }}}
" Printing {{{

" Shows line numbers and adjusts the left margin not to be ridiculous
set printoptions=number:y,left:5pc
set printfont=Monaco:h8         " face-type (not size) ignored in PostScript output :-(
set printencoding=utf-8

" }}}
" :Explore mode {{{

let g:netrw_hide=1          " Use the hiding list
" Hide the following file patterns (change to suit your needs):
" (I don't know what the fuck \~$ is, but file hiding seems to break without it appearing first in the list...)
let g:netrw_list_hide='\~$,\.pyc$,__init__\.py$'

" }}}
" Autocommands, plugin, and file-type-specific settings {{{

" Remember last position in file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

" Auto-set certain options as well as syntax highlighting and indentation
filetype plugin indent on

" Enables :make to compile, or validate, certain filetypes
" (use :cn & :cp to jump between errors)
au FileType xml,xslt compiler xmllint
au FileType html compiler tidy
au FileType java compiler javac

" For standards-compliant :TOhtml output
let html_use_css=1
let use_xhtml=1

" Helps if you have to use another editor on the same file
autocmd FileChangedShell *
    \ echohl WarningMsg |
    \ echo "File has been changed outside of vim." |
    \ echohl None

" For a full-screen help browser
" hit enter to activate links, and ctrl-[ as a back button
au FileType help nmap <buffer> <Return> <C-]>
au FileType help nmap <buffer> <C-[> <C-O>

" Matchit now ships with Vim!
" runtime! macros/matchit.vim

" Mappings for the ToggleComment Plugin
noremap <silent> ,# :call CommentLineToEnd('# ')<CR>+
noremap <silent> ,/ :call CommentLineToEnd('// ')<CR>+
noremap <silent> ," :call CommentLineToEnd('" ')<CR>+
noremap <silent> ,; :call CommentLineToEnd('; ')<CR>+
noremap <silent> ,- :call CommentLineToEnd('-- ')<CR>+
noremap <silent> ,* :call CommentLinePincer('/* ', ' */')<CR>+
noremap <silent> ,< :call CommentLinePincer('<!-- ', ' -->')<CR>+

" Centers, left, or right-justifies text
noremap <silent> ,c :ce <CR> << <CR>
noremap <silent> ,l :le <CR>
noremap <silent> ,r :ri <CR>

" Sets the default encoding to utf-8 if Vim was compiled with multibyte
if has("multi_byte")
    set encoding=utf-8
    if $TERM == "linux" || $TERM_PROGRAM == "GLterm"
        set termencoding=latin1
    endif
    if $TERM == "xterm" || $TERM == "xterm-color"
        let propv = system("xprop -id $WINDOWID -f WM_LOCALE_NAME 8s ' $0' -notype WM_LOCALE_NAME")
        if propv !~ "WM_LOCALE_NAME .*UTF.*8"
            set termencoding=latin1
        endif
    endif
endif

" }}}
" MyStatusLine {{{

function MyStatusLine()
    let s = '%3*' " User highlighting
    let s .= '%%%n '
    if bufname('') != '' " why is this such a pain in the ass?
        let s .= pathshorten(fnamemodify(expand('%F'), ':~')) " short-hand path of of the current buffer (use :ls to see more info)
    else
        let s .= '%F' " an empty filename doesn't make it through the above filters
    endif
    let s .= '%*' " restore normal highlighting
    let s .= '%2*' " User highlighting
    let s .= '%m' " modified
    let s .= '%r' " read-only
    let s .= '%w' " preview window
    let s .= '%*' " restore normal highlighting
    if bufname('#') != '' " if there's an alternate buffer, display the name
        let s .= '%<' " truncate the alternate buffer if the statusline is too long
        let s .= ' %4*' " user highlighting
        let s .= '(#' . bufnr('#') . ' '
        let s .= bufname('#')
        let s .= ')'
        let s .= '%*' " restore normal highlighting
        let s .= '%<' " truncate the alternate buffer if the statusline is too long
    endif
    let s .= ' %5*' " User highlighting
    let s .= '%y' " file-type
    let s .= '%*' " restore normal highlighting
    let s .= ' <'
    let s .= '%8*' " User highlighting
    let s .= '%{&fileencoding}' " fileencoding NOTE: this doesn't always display, needs more testing
    let s .= '%*,' " restore normal highlighting
    let s .= '%6*' " User highlighting
    let s .= '%{&fileformat}' " line-ending type
    let s .= '%*' " restore normal highlighting
    let s .= '>'
    let s .= '%<' " truncate the args of total if the statusline is too long
    let s .= '%a' " (args of total)
    let s .= '%<' " truncate the args of total if the statusline is too long
    let s .= '%=' " seperate right- from left-aligned
    let s .= '%7*' " user highlighting
    let s .= ' %{VimBuddy()} ' " Vimming will never be lonely again. TODO: check for plugin before loading
    let s .= '%*' " restore normal highlighting
    let s .= '%1*' " User highlighting
    let s .= '%l' " current line number
    let s .= '%*' " restore normal highlighting
    let s .= ',%c' " column number
    let s .= '%V' " virtual column number (doesn't count indentation)
    let s .= ' %1*' " User highlighting
    let s .= 'of %L' " total line numbers
    let s .= '%* ' " restore normal highlighting
    let s .= '%3*' " user highlighting
    let s .= '%P' " Percentage through file
    let s .= '%*' " restore normal highlighting
    return s
endfunction
set statusline=%!MyStatusLine()

" }}}

" eof
" vim:ft=vim:fdm=marker:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab

" let g:miniBufExplVSplit = 20 " vertical display
let g:miniBufExplSplitToEdge = 0
map <F2> :TMiniBufExplorer<cr>
map <F1> :ls<cr>
let g:miniBufExplorerMoreThanOne=6
let g:miniBufExplMapCTabSwitchBufs = 1 " I modified this to ctrl-h,l in the minibufexpl.vim script itself

"               It is possible to customize the the highlighting for the tabs in 
"               the MBE by configuring the following highlighting groups:
"
"                 MBENormal         - for buffers that have NOT CHANGED and
"                                     are NOT VISIBLE.
"                 MBEChanged        - for buffers that HAVE CHANGED and are
"                                     NOT VISIBLE
"                 MBEVisibleNormal  - buffers that have NOT CHANGED and are
"                                     VISIBLE
"                 MBEVisibleChanged - buffers that have CHANGED and are VISIBLE
"
"               You can either link to an existing highlighting group by
"               adding a command like:
"
"                 hi link MBEVisibleChanged Error
