" Best Goddamn vimrc in the whole world.
" Author: Seth House <seth@eseth.com>
" Modified: $LastChangedDate$
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

set nobackup                    "bk:    does not write a persistent backup file of an edited file
set writebackup                 "wb:    does keep a backup file while editing a file

" Searches the current directory as well as subdirectories with commands like :find, :grep, etc.
set path=.,**

set cindent                     "cin:   enables the second-most configurable indentation (see :help C-indenting).
set cinoptions=l1,c4,(s,U1,w1,m1,j1
set cinwords=if,elif,else,for,while,try,except,finally,def,class

set expandtab                   "et:    uses spaces instead of tab characters
set smarttab                    "sta:   helps with backspacing because of expandtab
set softtabstop=4               "ts:    number of spaces that a tab counts for
set shiftwidth=4                "sw:    number of spaces to use for autoindent
set shiftround                  "sr:    rounds indent to a multiple of shiftwidth

set nojoinspaces                "nojs:  prevents inserting two spaces after punctuation on a join (it's not 1990 anymore)
set lazyredraw                  "lz:    will not redraw the screen while running macros (goes faster)
set pastetoggle=<F5>            "pt:    useful so auto-indenting doesn't mess up code when pasting

" Fix for legacy vi inconsistency
map Y y$

" Shortcut to add new blank line without entering insert mode
noremap <CR> :put_<CR>

" A shortcut to show the numbered register contents
map <F2> :reg "0123456789-*+:/<CR>

"lcs:   displays tabs with :set list & displays when a line runs off-screen
set listchars=tab:>-,eol:$,trail:-,precedes:<,extends:>

" Toggle hidden characters display
map <silent> <F6> :set nolist!<CR>:set nolist?<CR>

" Toggle spell-checking
map <silent> <F8> :set nospell!<CR>:set nospell?<CR>

" Maps Omnicompletion to CTRL-space since ctrl-x ctrl-o is for Emacs-style RSI
inoremap <Nul> <C-x><C-o>

" VCS Diffs
" Small, fast, windowed diff
noremap <silent> ,hq :new +:read\ !hg\ diff\ #<CR>:exe Scratch()<CR>:set filetype=diff<CR>:set nofoldenable<CR>
noremap <silent> ,sq :new +:read\ !svn\ diff\ #<CR>:exe Scratch()<CR>:set filetype=diff<CR>:set nofoldenable<CR>
" Big, slow, fancy, tabbed vimdiff. When you're done just :tabclose the tab.
noremap <silent> ,hd :tabnew %<CR> :vnew +:read\ !hg\ cat\ #<CR>:exe Scratch()<CR>:diffthis<CR><C-W>w :diffthis<CR>:set syntax=off<CR>
noremap <silent> ,sd :tabnew %<CR> :vnew +:read\ !svn\ cat\ #<CR>:exe Scratch()<CR>:diffthis<CR><C-W>w :diffthis<CR>:set syntax=off<CR>

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
set sidescroll=2                "ss:    only scroll horizontally little by little
set scrolloff=1                 "so:    places a line between the current line and the screen edge
set sidescrolloff=2             "siso:  places a couple columns between the current column and the screen edge
set laststatus=2                "ls:    makes the status bar always visible
set ttyfast                     "tf:    improves redrawing for newer computers
set viminfo='100,f1,:100,/100   "vi:    For a nice, huuuuuge viminfo file

if &columns == 80
    " If we're on an 80-char wide term, don't display these screen hogs
    set nonumber
    set foldcolumn=0
endif

" }}}
" Multi-buffer/window/tab editing {{{

set switchbuf=useopen           "swb:   Jumps to first window or tab that contains specified buffer instead of duplicating an open window
set showtabline=1               "stal:  Display the tabbar if there are multiple tabs. Use :tab ball or invoke Vim with -p
set hidden                      "hid:   allows opening a new buffer in place of an existing one without first saving the existing one

set splitright                  "spr:   puts new vsplit windows to the right of the current
set splitbelow                  "sb:    puts new split windows to the bottom of the current

set winminheight=0              "wmh:   the minimal line height of any non-current window
set winminwidth=0               "wmw:   the minimal column width of any non-current window

" Type <F1> follwed by a buffer number or name fragment to jump to it.
" Also replaces the annoying help button. Based on tip 821.
map <F1> :ls<CR>:b<Space>

" Earlier Vims did not support tabs. Below is a vertical-tab-like cludge. Use
" :ball or invoke Vim with -o (Vim tip 173)
if version < 700
    " ctrl-j,k will move up or down between split windows and maximize the
    " current window
    nmap <C-J> <C-W>j<C-W>_
    nmap <C-K> <C-W>k<C-W>_
else
    " same thing without the maximization to easily move between split windows
    nmap <C-J> <C-W>j
    nmap <C-K> <C-W>k
    nmap <C-H> <C-W>h
    nmap <C-L> <C-W>l
endif

" When restoring a hidden buffer Vim doesn't always keep the same view (like
" when your view shows beyond the end of the file). (Vim tip 1375)
if v:version >= 700
    au BufLeave * let b:winview = winsaveview()
    au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif

" }}}
" X11 Integration {{{
" (I.e.: don't do any automatic integration, please :)

set mouse=                      "       Disable mouse control for console Vim (very annoying)
set clipboard=                  "       Disable automatic X11 clipboard crossover

" }}}
" Color {{{
"   All coloring options are for the non-GUI Vim (see :help cterm-colors).

color desert

" I love the new CursorLine, but terminal underlining kicks legibility in the nuts.
" So what to do? Bold is (extremely) subtle, but it's better than nothing.
hi CursorLine cterm=bold

" Statusline
" I like this better than all the reverse video of the default statusline.
hi StatusLine term=bold,reverse cterm=bold ctermfg=7 ctermbg=none
hi StatusLineNC term=reverse cterm=bold ctermfg=8
hi User1 ctermfg=4
hi User2 ctermfg=1
hi User3 ctermfg=5
hi User4 cterm=bold ctermfg=8
hi User5 ctermfg=6
hi User6 ctermfg=2
hi User7 ctermfg=2
hi User8 ctermfg=3
hi User9 cterm=reverse ctermfg=8 ctermbg=7

" Darkens the status line for non-active windows. Needs testing!
au BufEnter * hi User9 ctermfg=7

" A nice, minimalistic tabline
hi TabLine cterm=bold,underline ctermfg=8 ctermbg=none
hi TabLineSel cterm=bold ctermfg=0 ctermbg=7
hi TabLineFill cterm=bold ctermbg=none

" }}}
" Printing {{{

" Shows line numbers and adjusts the left margin not to be ridiculous
set printoptions=number:y,left:5pc
set printfont=Monaco:h8         " face-type (not size) ignored in PostScript output :-(
set printencoding=utf-8

" }}}
" :Explore mode {{{

" NERDTree is a pretty slick (partial) replacement for :Explore
let NERDTreeIgnore=['\.pyc$']
map <F4> :NERDTreeToggle<cr>

let g:netrw_hide=1          " Use the hiding list
" Hide the following file patterns (change to suit your needs):
" (I don't know what the fuck \~$ is, but file hiding seems to break without it appearing first in the list...)
let g:netrw_list_hide='^\..*,\.pyc$'

" Commands for :Explore (verify these!)
let g:explVertical=1    " open vertical split winow
let g:explSplitRight=1  " Put new window to the right of the explorer
let g:explStartRight=0  " new windows go to right of explorer window

" Tree view. Adaptable?
" ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'

" }}}

" YankList {{{1
" Is is possbile to store the ten most recent yanks using opfunc (similar to
" the built-in numbered registers)?
" NOTE: work in progress

noremap <silent> gy :set opfunc=YankList<CR>g@
vmap <silent> gy :<C-U>call YankList(visualmode(), 1)<CR>
map <silent> gyy Y

function! YankList(type, ...)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@

    echo "Something was copied!\n"

    if a:0  " Invoked from Visual mode, use '< and '> marks.
        silent exe "normal! `<" . a:type . "`>y"
    elseif a:type == 'line' " Line
        silent exe "normal! '[V']y"
    elseif a:type == 'block' " Block
        silent exe "normal! `[\<C-V>`]y"
    else " ???
        silent exe "normal! `[v`]y"
    endif
endfunction

" }}}
" MyStatusLine {{{

" TODO: add a check for screen width and remove the alternate buffer display
" and args of total display for small screen widths.
function! MyStatusLine()
    let s = '%9* %* ' " pad the edges for better vsplit seperation
    let s .= '%3*' " User highlighting
    let s .= '%%%n '
    if bufname('') != '' " why is this such a pain in the ass? FIXME: there's a bug in here somewhere. Test with a split with buftype=nofile
        let s .= "%{ pathshorten(fnamemodify(expand('%F'), ':~:.')) }" " short-hand path of of the current buffer (use :ls to see more info)
    else
        let s .= '%f' " an empty filename doesn't make it through the above filters
    endif
    let s .= '%*' " restore normal highlighting
    let s .= '%2*' " User highlighting
    let s .= '%m' " modified
    let s .= '%r' " read-only
    let s .= '%w' " preview window
    let s .= '%*' " restore normal highlighting
    let s .= ' %<' " start truncating from here if the window gets too small
    " FIXME: this doens't work well with multiple windows...
    if bufname('#') != '' " if there's an alternate buffer, display the name
        let s .= '%4*' " user highlighting
        let s .= '(#' . bufnr('#') . ' '
        let s .= fnamemodify(bufname('#'), ':t')
        let s .= ')'
        let s .= '%* ' " restore normal highlighting
    endif
    let s .= '%5*' " User highlighting
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
    let s .= '%a' " (args of total)
    let s .= '  %9*' " user highlighting
    let s .= '%=' " seperate right- from left-aligned
    let s .= '%*' " restore normal highlighting
    let s .= '%7*' " user highlighting
    let s .= '  %{VimBuddy()} ' " Vimming will never be lonely again. TODO: check for plugin before loading
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
    let s .= ' %9* %*' " pad the edges for better vsplit seperation
    return s
endfunction
set statusline=%!MyStatusLine()

" }}}

" Autocommands, plugin, and file-type-specific settings {{{

" Remember last position in file
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Auto-set certain options as well as syntax highlighting and indentation
filetype plugin indent on

" Set Omnicompletion for certain filetypes
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

" Not sure why the cron filetype isn't catching this...
au FileType crontab set backupcopy=yes

" Enables :make to compile, or validate, certain filetypes
" (use :cn & :cp to jump between errors)
au FileType xml,xslt compiler xmllint
au FileType html compiler tidy
au FileType java compiler javac

" Python :make
autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

" Set keywordprg for certain filetypes
au FileType python set keywordprg=pydoc

" Python :make for a small visual selection of code
python << EOL
import vim
def EvaluateCurrentRange():
    eval(compile('\n'.join(vim.current.range),'','exec'),globals())
EOL
" map <C-m> :py EvaluateCurrentRange()

" For standards-compliant :TOhtml output
let html_use_css=1
let use_xhtml=1

" Helps if you have to use another editor on the same file
autocmd FileChangedShell *
    \ echohl WarningMsg |
    \ echo "File has been changed outside of vim." |
    \ echohl None

" Vim Help docs: hit enter to activate links, and ctrl-[ as a back button
au FileType help nmap <buffer> <Return> <C-]>
au FileType help nmap <buffer> <C-[> <C-O>

" Mappings for the ToggleComment Plugin
noremap <silent> ,# :call CommentLineToEnd('# ')<CR>+
noremap <silent> ,/ :call CommentLineToEnd('// ')<CR>+
noremap <silent> ," :call CommentLineToEnd('" ')<CR>+
noremap <silent> ,; :call CommentLineToEnd('; ')<CR>+
noremap <silent> ,- :call CommentLineToEnd('-- ')<CR>+
noremap <silent> ,* :call CommentLinePincer('/* ', ' */')<CR>+
noremap <silent> ,< :call CommentLinePincer('<!-- ', ' -->')<CR>+

" Custom settings for the taglist plugin (see ~/.ctags file)
" /regexp/replacement/[kind−spec/][flags]
map <F3> :TlistToggle<cr>
let Tlist_Use_Right_Window = 1
let Tlist_Compact_Format = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_File_Fold_Auto_Close = 1
let tlist_xml_settings = 'xml;i:id'
let tlist_xhtml_settings = tlist_xml_settings
let tlist_html_settings = tlist_xml_settings
let tlist_htmldjango_settings = tlist_xml_settings
let tlist_css_settings = 'css;s:Selectors'

" Centers, left, or right-justifies text
noremap <silent> ,c :ce <CR> << <CR>
noremap <silent> ,l :le <CR>
noremap <silent> ,r :ri <CR>

" Makes the current buffer a scratch buffer
function! Scratch()
    set buftype=nofile
    set bufhidden=delete
    set noswapfile
endfunction
noremap <silent> ,s :exe Scratch()<CR>

" Outputs a small warning when opening a file that contains tab characters
function! WarnTabs()
    if searchpos('\t') != [0,0]
        echohl WarningMsg |
        \ echo "Warning, this file contains tabs." |
        \ echohl None
    endif
endfunction
autocmd BufReadPost * call WarnTabs()

" }}}

" eof
" vim:ft=vim:fdm=marker:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
