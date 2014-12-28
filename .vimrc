" Best Goddamn vimrc in the whole world.
" Author: Seth House <seth@eseth.com>
" For more information type :help followed by the command.

filetype plugin indent on
call pathogen#infect()

" Search {{{

set incsearch                   " Automatically begins searching as you type
set ignorecase                  " Ignores case when pattern matching
set smartcase                   " Ignores ignorecase when pattern contains uppercase characters
set hlsearch                    " Highlights search results

" Use leader-n to unhighlight search results in normal mode:
nmap <silent> <leader>n :silent noh<cr>

" Display the number of matches for the last search
nmap <leader># :%s:<C-R>/::gn<cr>

" Restore case-sensitivity for jumping to tags (set ic disables it)
map <silent> <C-]> :set noic<cr>g<C-]><silent>:set ic<cr>

" }}}
" Line Wrap {{{

set backspace=indent,eol,start  " Allows you to backspace over the listed character types
set linebreak                   " Causes vim to not wrap text in the middle of a word
set wrap                        " Wraps lines by default

" Toggle line wrapping in normal mode:
nmap <silent> <C-P> :set nowrap!<cr>:set nowrap?<cr>

" }}}
" Editing {{{

set showmatch                   " Flashes matching brackets or parentheses

set nobackup                    " Does not write a persistent backup file of an edited file
set writebackup                 " Does keep a backup file while editing a file

set undofile                    " Persist the undo tree to a file; dir below will not be auto-created
set undodir=$HOME/.vim/undodir,.
set directory=$HOME/.vim/swapdir,.

" Searches the current directory as well as subdirectories with commands like :find, :grep, etc.
set path=.,**

set cindent                     " Enables the second-most configurable indentation (see :help C-indenting).
set cinoptions=l1,c4,(s,U1,w1,m1,j1,J1

set formatoptions+=j            " Remove comment leader when joining lines

set expandtab                   " Uses spaces instead of tab characters
set smarttab                    " Helps with backspacing because of expandtab
set softtabstop=4               " Number of spaces that a tab counts for
set shiftwidth=4                " Number of spaces to use for autoindent
set shiftround                  " Rounds indent to a multiple of shiftwidth

set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (it's not 1990 anymore)
set lazyredraw                  " Will not redraw the screen while running macros (goes faster)
set pastetoggle=<F9>            " Useful so auto-indenting doesn't mess up code when pasting

set complete-=t,i               " Remove tags and included files from default insert completion

set virtualedit=block           " Let cursor move past the last char in <C-V> mode
set nostartofline               " Avoid moving cursor to BOL when jumping around

set cryptmethod=blowfish        " Use (much) stronger blowfish encryption

" Fix for legacy vi inconsistency
map Y y$

" Use the repeat operator with a visual selection
" This is useful for performing an edit on a single line, then highlighting a
" visual block on a number of lines to repeat the edit.
vnoremap <leader>. :normal .<cr>

" Repeat a macro on a visual selection of lines
" Same as above but with a macro; complete the command by chosing the register
" containing the macro.
vnoremap <leader>@ :normal @

" Allow undoing individual insert-mode changes with ctrl-u and ctrl-w
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" Add a line without changing position or leaving mode
map <leader>o :set paste<cr>m`o<esc>``:set nopaste<cr>
map <leader>O :set paste<cr>m`O<esc>``:set nopaste<cr>

" A shortcut to show the numbered register contents
map <F2> :reg "0123456789-*+:/<cr>

set colorcolumn=80              " Draw a visual line down the 80th column

" Toggle between line numbers and relative line numbers
nnoremap <silent><leader>u :exe "set " . (&rnu == 1 ? "nornu" : "rnu")<cr>

" Displays tabs with :set list & displays when a line runs off-screen
set listchars=tab:>-,trail:\ ,precedes:<,extends:>

" Show listchars; highlight lines more than 80 chars, trailing spaces, only
" whitespace. Toggle with \l
nnoremap <silent> <leader>l
      \ :set nolist!<cr>:set nolist?<cr>
      \ :if exists('w:long_line_match') <bar>
      \   silent! call matchdelete(w:long_line_match) <bar>
      \   unlet w:long_line_match <bar>
      \ elseif &textwidth > 0 <bar>
      \   let w:long_line_match = matchadd('ErrorMsg', '\%>'.&tw.'v.\+', -1) <bar>
      \ else <bar>
      \   let w:long_line_match = matchadd('ErrorMsg', '\%>80v.\+', -1) <bar>
      \ endif<cr>

" Toggle spell-checking
map <silent> <F10> :set nospell!<cr>:set nospell?<cr>

" Maps Omnicompletion to CTRL-space.
inoremap <nul> <C-X><C-O>

" Don't select first autocomplete item, follow typing.
set completeopt=longest,menuone,preview

" Change directory to the path of the current file
map <leader>cd :cd %:p:h<cr>

" Edit a new file starting in the same dir as the current file
map <leader>ce :e <C-R>=expand("%:p:h") . "/" <cr>
map <leader>cs :sp <C-R>=expand("%:p:h") . "/" <cr>
map <leader>ct :tabnew <C-R>=expand("%:p:h") . "/" <cr>

" Find merge conflict markers
map <leader>fc /\v^[<=>]{7}( .*\|$)<cr>

set dictionary=spell        " Complete words from the spelling dict.

" Use generic omnicompletion if something more specific isn't already set
if has("autocmd") && exists("+omnifunc")
    au Filetype *
        \ if &omnifunc == "" | setl omnifunc=syntaxcomplete#Complete | endif
endif

if has("autocmd")
    " Helps if you have to use another editor on the same file
    au FileChangedShell * Warn "File has been changed outside of Vim."
endif

" Restore last cursor position in file
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" If a ftplugin has defined the b:ftskeleton variable, try to load the
" skeleton template.
au BufNewFile * silent! exe "0r ". b:ftskeleton

" Insert timestamps by calling out to date; override format by filetype
let b:dateformat = ''
nmap <silent> <leader>dts :exe ':r !date '. escape(b:dateformat, '%')<cr>

" }}}
" Folding (spacebar toggles) {{{
" Spacebar toggles a fold, zi toggles all folding, zM closes all folds

noremap  <silent>  <space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<cr>

set foldmethod=marker           "fdm:   looks for patterns of triple-braces in a file
set foldcolumn=4                "fdc:   creates a small left-hand gutter for displaying fold info

" }}}
" Menu completion {{{

set suffixes+=.pyc,.pyo         " Don't autocomplete these filetypes
set wildmenu                    "wmnu:  enhanced ex command completion
set wildmode=longest:full,list:full  "wim:   helps wildmenu auto-completion

" }}}
" Window Layout {{{

set encoding=utf-8
set relativenumber              "rnu:   show line numbers relative to the current line; <leader>u to toggle
set number                      "nu:    show the actual line number for the current line in relativenumber
set showmode                    "smd:   shows current vi mode in lower left
set cursorline                  "cul:   highlights the current line
set showcmd                     "sc:    shows typed commands
set cmdheight=2                 "ch:    make a little more room for error messages
set sidescroll=2                "ss:    only scroll horizontally little by little
set scrolloff=1                 "so:    places a line between the current line and the screen edge
set sidescrolloff=2             "siso:  places a couple columns between the current column and the screen edge
set laststatus=2                "ls:    makes the status bar always visible
set ttyfast                     "tf:    improves redrawing for newer computers
set history=200                 "hi:    number of search patterns and ex commands to remember
                                "       (also used by viminfo below for /, :, and @ options)
set viminfo='200                "vi:    For a nice, huuuuuge viminfo file

if &columns < 88
    " If we can't fit at least 80-cols, don't display these screen hogs
    set nonumber
    set foldcolumn=0
endif

" }}}
" Multi-buffer/window/tab editing {{{

set switchbuf=usetab            " Jumps to first tab or window that contains specified buffer instead of duplicating an open window
set showtabline=1               " Display the tabbar if there are multiple tabs. Use :tab ball or invoke Vim with -p
set hidden                      " Allows opening a new buffer in place of an existing one without first saving the existing one

" Type <F1> follwed by a buffer number or name fragment to jump to it.
" Also replaces the annoying help button. Based on tip 821.
map <F1> :ls<cr>:b<space>

" Quickly jump to a tag if there's only one match, otherwise show the list
map <F3> :tj<space>

" Display a list of included files and quickly jump to one
map <F4> [I:let nr = input("Which one: ")<bar>exe "normal " . nr ."[\t"<cr>

" When restoring a hidden buffer Vim doesn't always keep the same view (like
" when your view shows beyond the end of the file). (Vim tip 1375)
if ! &diff
    au BufLeave * let b:winview = winsaveview()
    au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif

" Shortcuts for working with quickfix/location lists
nmap ]q :cnext<cr>
nmap [q :cprev<cr>
nmap ]Q :clast<cr>
nmap [Q :cfirst<cr>

" Disable one diff window during a three-way diff allowing you to cut out the
" noise of a three-way diff and focus on just the changes between two versions
" at a time. Inspired by Steve Losh's Splice
function! DiffToggle(window)
    " Save the cursor position and turn on diff for all windows
    let l:save_cursor = getpos('.')
    windo :diffthis

    " Turn off diff for the specified window (but keep scrollbind) and move
    " the cursor to the left-most diff window
    exe a:window . "wincmd w"
    diffoff
    set scrollbind
    set cursorbind
    exe a:window . "wincmd " . (a:window == 1 ? "l" : "h")

    " Update the diff and restore the cursor position
    diffupdate
    call setpos('.', l:save_cursor)
endfunction
" Toggle diff view on the left, center, or right windows
nmap <silent> <leader>dl :call DiffToggle(1)<cr>
nmap <silent> <leader>dm :call DiffToggle(2)<cr>
nmap <silent> <leader>dr :call DiffToggle(3)<cr>
nmap <silent> <leader>du :diffupdate<cr>


" }}}
" X11 Integration {{{
" (I.e.: don't do any automatic integration, please :)

set mouse=                      " Disable mouse control for console Vim (very annoying)
set clipboard=                  " Disable automatic X11 clipboard crossover

" }}}
" Color {{{
"   All coloring options are for the non-GUI Vim (see :help cterm-colors).

" Make listchars (much) more noticable.
au ColorScheme * hi SpecialKey ctermfg=7 ctermbg=1

" A nice, minimalistic tabline.
au ColorScheme * hi TabLine cterm=bold,underline ctermfg=8 ctermbg=none
au ColorScheme * hi TabLineSel cterm=bold ctermfg=0 ctermbg=7
au ColorScheme * hi TabLineFill cterm=bold ctermbg=none

" Black ColorColumn to not catch the eye more than is necessary
au ColorScheme * hi ColorColumn ctermbg=0

" Makes the current line stand out with bold and in the numberline
au ColorScheme * hi CursorLine cterm=bold
au ColorScheme * hi LineNr cterm=bold ctermfg=0 ctermbg=none

" Match the Sign column to the number column
au ColorScheme * hi SignColumn cterm=bold ctermfg=0 ctermbg=none

" Refresh busted syntax highlighting (this happens too often)
map <F12> :syntax sync fromstart<cr>

" Shorten the timeout when looking for a paren match to highlight
let g:matchparen_insert_timeout = 5
set synmaxcol=500               " Stop syntax highlighting on very long lines

syntax enable
colorscheme desert

" }}}
" Printing {{{

" Shows line numbers and adjusts the left margin not to be ridiculous
set printoptions=number:y,left:5pc
set printfont=Monaco:h8         " face-type (not size) ignored in PostScript output :-(
set printencoding=utf-8

" }}}
" :Explore mode {{{

" Hide the following file patterns.
let g:netrw_hide = 1
let g:netrw_list_hide = '^\..*,\.pyc$'

" Default to thin, vertical Explore windows that output tree view.
let g:netrw_preview = 1
let g:netrw_winsize = 30
let g:netrw_liststyle = 3

" }}}

" Scripting helpers {{{1

command -nargs=1 Warn echohl WarningMsg | echo <args> | echohl None

" }}}
" Make the current buffer a scratch buffer {{{1

function! Scratch()
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    Warn "This file is now a scratch file!"
endfunction
nmap <silent> <leader>S :call Scratch()<cr>

" }}}
" Diff two registers {{{
" Open a diff of two registers in a new tabpage. Close the tabpage when
" finished. If no registers are specified it diffs the most recent yank with
" the most recent deletion.
" Usage:
"   :DiffRegs
"   :DiffRegs @a @b

function! DiffRegsFunc(...)
    let l:left = a:0 == 2 ? a:1 : "@0"
    let l:right = a:0 == 2 ? a:2 : "@1"

    tabnew
    exe 'put! ='. l:left
    vnew
    exe 'put! ='. l:right

    windo call Scratch()
    windo diffthis
    winc t
endfunction
command! -nargs=* DiffRegs call DiffRegsFunc(<f-args>)

" }}}
" YankList {{{1
" Is is possbile to store the ten most recent yanks using opfunc (similar to
" the built-in numbered registers)?
" NOTE: work in progress, this is currently non-functional

" noremap <silent> gy :set opfunc=YankList<cr>g@
" vmap <silent> gy :<C-U>call YankList(visualmode(), 1)<cr>
" map <silent> gyy Y

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
" MyTabLine {{{
" Number the tabs.

function! MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1

    while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let winnr = tabpagewinnr(i)
        let curwinnr = tabpagewinnr(i,'$')

        let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
        let s .= '%' . i . 'T'
        let s .= ' '  . i . ': '
        let file = bufname(buflist[winnr - 1])
        let file = fnamemodify(file, ':p:t')
        if file == ''
            let file = '[No Name]'
        endif
        let s .= file
        let s .= (curwinnr > 1 ? ' (' . curwinnr .') ' : '')
        let s .= ' '
        let i = i + 1
    endwhile
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
endfunction

set tabline=%!MyTabLine()

" }}}
" SplitItems Break out vals with a consistent delimiter on to separate lines {{{
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
" FIXME: currently joining does not include the text-object chars
" TODO: visual selection support; some text objects are not multi-line (",')

function! SplitItems(type, ...)
    let c = input("Split on what chars? ", ", ")
    normal! `[v`]x
    let @@ = substitute(@@, c, '\n', 'g')
    set paste
    exe "normal! i\<cr>\<esc>"
    pu! "
    set nopaste
endfunction
nnoremap <leader>s :set opfunc=SplitItems<cr>g@

function! JoinItems(type, ...)
    let c = input("Join with what chars? ", ", ")
    normal! `[v']d
    let @@ = substitute(@@, '\n', c, 'g')
    set paste
    exe "normal! P\<esc>"
    set nopaste
endfunction
nnoremap <leader>j :set opfunc=JoinItems<cr>g@

" }}}
" Plugin settings {{{

""" Enable builtin matchit plugin
runtime macros/matchit.vim

""" Wordnet settings
noremap  <F11> "wyiw:call WordNetOverviews(@w)<cr>

""" Gundo settings
nnoremap <F7> :GundoToggle<cr>

""" Syntastic settings
let g:syntastic_enable_highlighting = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_error_symbol = 'E'
let g:syntastic_style_error_symbol = 'S'
let g:syntastic_warning_symbol = 'W'
let g:syntastic_style_warning_symbol = 'S'
let g:syntastic_always_populate_loc_list = 1
nmap <silent> <leader>y :SyntasticCheck<cr>

if ! &diff
    let g:syntastic_check_on_open = 1
endif

""" signify settings
let g:signify_vcs_list = ['git']
hi SignifySignAdd    ctermfg=2
hi SignifySignDelete ctermfg=1
hi SignifySignChange ctermfg=3

""" Fugitive settings
" Open current buffer in a new tab and show Fugitive diff
nmap <silent> <leader>dd :tab split \| Gdiff \| wincmd h<cr>
nmap <silent> <leader>dc :Gcommit<cr>
nmap <silent> <leader>da :Gcommit --amend --reuse-message=HEAD<cr>

""" Tagbar plugin settings
map <F5> :TagbarToggle<cr>
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_width = 25
let g:tagbar_iconchars = ['+', '-']

" Auto-open tagbar only if not in diff mode and the term wide enough to also
" fit an 80-column window (plus eight for line numbers and the fold column).
if &columns > 118
    if ! &diff
        au VimEnter * nested :call tagbar#autoopen(1)
    endif
else
    let g:tagbar_autoclose = 1
    let g:tagbar_autofocus = 1
endif

""" Airline settings
" let g:airline_powerline_fonts = 1
let g:airline_detect_whitespace = 2
let g:airline_whitespace_symbol = 'Ξ'
let g:airline_linecolumn_prefix = '␊ '
let g:airline_left_sep = '▞'
let g:airline_right_sep = '▚'
" Add the alternate buffer name next to the current file name
let g:airline_section_c = "%f%m %{bufname('#') != '' ? '('. expand('#:t') .')' : ''}"

" Dispatch mappings
nmap <silent> <leader>b :Make!<cr>

" }}}

" eof
" vim:ft=vim:fdm=marker:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
