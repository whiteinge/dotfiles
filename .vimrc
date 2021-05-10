filetype plugin on
filetype indent off

" Search {{{

set ignorecase                  " Ignores case when pattern matching
set smartcase                   " Ignores ignorecase when pattern contains uppercase characters
set hlsearch                    " Highlights search results
set shortmess-=S                " Show current/total search matches.

" Map n/N to always move in the same direction.
nn <expr> n 'Nn'[v:searchforward]
nn <expr> N 'nN'[v:searchforward]

" Search for the word under the cursor (but don't advance to the first match)
" https://www.reddit.com/r/vim/comments/vzd0q/how_do_i_set_the_search_pattern_without_moving/c5a5m4z
nn <silent> * :let @/ = '\<' .  expand('<cword>') . '\>'
  \\| call histadd('/', @/)
  \\| if &hlsearch != 0 \| set hlsearch \| endif
  \\| echo '/'. @/ .'/=' execute('%s///gn')<cr>

set grepprg=ggrep

" grep for the word under the cursor.
nn <silent> <leader>* :grep <cword><cr>

" grep all files in the arglist.
com! -nargs=* Greparglist grep <args> ##

" grep across all loaded buffers.
com! -nargs=* Grepbuflist call range(0, bufnr('$'))
    \ ->filter({i, x -> buflisted(x)})
    \ ->map({i, x -> fnameescape(bufname(x))})
    \ ->join(' ')
    \ ->M('grep <args> ')
    \ ->execute()

" grep all files in the quickfix list.
com! -nargs=* Grepqflist call getqflist()
    \ ->map({i, x -> fnameescape(bufname(x.bufnr))})
    \ ->sort() ->uniq() ->join(' ')
    \ ->M('grep <args> ')
    \ ->execute()

" Use leader-n to unhighlight search results in normal mode:
nm <silent> <leader>n :silent noh<cr>
nm <silent> <leader>N :set hls<cr>

" Display the number of matches for the last search
nm <leader># :%s///gn<cr>

" Highlight arbitrary text (separately from searching); accepts a count and
" highlights the text under the cursor. Ranges from 1-9; see the corresponding
" highlights in the Colors section below.
" Usage: 1\hh or 2\hh or 3\hh, etc.
nn <leader>hh :<c-u>call matchadd('Match'. v:count1, expand('<cword>'),
    \ v:count1, v:count1 + 10)<cr>
" Clear individual matches: 1\hn or 2\hn or 3\hn, etc.
nn <leader>hH :<c-u>call matchdelete(v:count1 + 10)<cr>
" Clear all matches:
nn <leader>hn :call clearmatches()<cr>

" }}}
" Line Wrap {{{

set linebreak                   " Causes vim to not wrap text in the middle of a word
set wrap                        " Wraps lines by default

" Toggle line wrapping in normal mode:
nmap <silent> <C-P> :set nowrap!<cr>:set nowrap?<cr>

" }}}
" Editing {{{

set showmatch                   " Flashes matching brackets or parentheses

set backup                      " Does write a persistent backup file of an edited file
set writebackup                 " Does keep a backup file while editing a file

set undofile                    " Persist the undo tree to a file; dir below will not be auto-created
set backupdir=$HOME/.vim/backupdir,.
set undodir=$HOME/.vim/undodir,.
set directory=$HOME/.vim/swapdir,.

set autoindent

set formatoptions=
set formatoptions+=t            " Wrap when using textwidth
set formatoptions+=c            " Wrap comments too
set formatoptions+=q            " Format comments with gq
set formatoptions+=j            " Remove comment leader when joining lines
set formatoptions+=1            " Break before 1-letter words
set formatoptions+=n            " Recognize numbered lists
" Don't let ftplugins override formatoptions
au FileType * set fo=tcqj1n

" Un-fuck '*' in formatlistpat.
setl comments=

" Better indention/ hierarchy
" https://www.reddit.com/r/vim/comments/4wmugj/enhance_vim_as_a_writing_environment/d68sfgj
let formatlistpat='
    \^\s*
    \[
    \\[({]\?
    \\(
    \[0-9]\+
    \\|[iIvVxXlLcCdDmM]\+
    \\|[a-zA-Z]
    \\)
    \[\]:.)}
    \]
    \\s\+
    \\|^\s*[-–+o*•]\s\+
    \'
" ) Fix broken syntax highlighting.
let &flp=formatlistpat
" Don't let ftplugins override formatoptions
au FileType * let &flp=formatlistpat

set expandtab                   " Uses spaces instead of tab characters
set smarttab                    " Helps with backspacing because of expandtab
set softtabstop=4               " Number of spaces that a tab counts for
set shiftwidth=4                " Number of spaces to use for autoindent
set shiftround                  " Rounds indent to a multiple of shiftwidth

set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (it's not 1990 anymore)
set lazyredraw                  " Will not redraw the screen while running macros (goes faster)
set pastetoggle=<F9>            " Useful so auto-indenting doesn't mess up code when pasting

set nostartofline               " Avoid moving cursor to BOL when jumping around
set virtualedit=block           " Let cursor move past the last char in <C-V> mode

" Toggle virtualedit
" Useful for ascii art and for transposing columns with a visual selection.
com! Drawmode exe "set ve=". (&ve == "all" ? "block" : "all") | echo &ve

set cryptmethod=blowfish2       " Use (much) stronger blowfish encryption

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
inoremap <C-W> <C-G>u<C-W>

" Select most recently edited text.
nnoremap <leader>v `[v`]

" Add a line without changing position or leaving mode
map <leader>o :set paste<cr>m`o<esc>``:set nopaste<cr>
map <leader>O :set paste<cr>m`O<esc>``:set nopaste<cr>

" Toggle between line numbers and relative line numbers
nnoremap <silent> <leader>u :exe "set " . (&rnu == 1 ? "nornu" : "rnu")<cr>

" Change j and k to add movements to the jump list.
nnoremap <expr> k (v:count > 1 ? "m'". v:count : '') . 'gk'
nnoremap <expr> j (v:count > 1 ? "m'". v:count : '') . 'gj'

" Clear the jump list on startup.
" I have never once remembered the jumplist between multiple Vim sessions.
" Starting from a zero state each session lets me rewind/fast-forward through
" the current session movements without accidentally entering a previous and
" long-forogtten session.
au VimEnter * clearjumps

" Displays tabs with :set list & displays when a line runs off-screen
set listchars=tab:>-,trail:\ ,precedes:<,extends:>,eol:$,nbsp:%

" Show listchars and cursorcolumn; highlight lines more than 80 chars, trailing
" spaces, only whitespace.
nnoremap <silent> <leader>ll
    \ :set nolist!<cr>:set nolist?<cr> <bar>
    \ :set cursorcolumn!<cr>:silent set cursorcolumn?<cr> <bar>
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

" Change directory to the path of the current file; and back again
map <leader>cd :lcd %:p:h<cr><bar>:pwd<cr>
map <leader>cc :lcd -<cr><bar>:pwd<cr>

" Make necessary directories to be able to write the current file
com! Mkdirwrite call util#SysR('', 'mkdir -p '. expand('%:h')) | execute('w')

" Helps if you have to use another editor on the same file
au FileChangedShell * echo "File has been changed outside of Vim."

" If a ftplugin has defined the b:ftskeleton variable, try to load the
" skeleton template.
au BufNewFile * silent! exe "0r ". b:ftskeleton

" Insert timestamps by calling out to date; override format by filetype
let b:dateformat = ''
nmap <silent> <leader>dts :exe ':r !date '. escape(b:dateformat, '%')<cr>

" Mapping to write a file using sudo
com! Sudowrite write !sudo tee % >/dev/null

" Use command mode readline/Emacs shortcut to go to the beginning of the line.
" I can never remember Vim's default. Where does that ctrl-b come from?
cnoremap <C-a> <Home>

" Add thumbs-up/down emoji as digraphs
dig +1 128077
dig -1 128078

" }}}
" Folding {{{
" zA toggles a fold, zi toggles all folding, zM closes all folds

set foldmethod=marker           "fdm:   looks for patterns of triple-braces in a file
set foldcolumn=4                "fdc:   creates a small left-hand gutter for displaying fold info

" }}}
" Menu completion {{{

set wildmenu                    "wmnu:  enhanced ex command completion
set wildmode=longest:full,list:full  "wim:   helps wildmenu auto-completion

set dictionary=spell        " Complete words from the spelling dict.
set complete-=t,i           " Remove tags and included files from default insert completion

" Maps Omnicompletion to CTRL-space.
inoremap <nul> <C-X><C-O>

" Maps file completion relative to current file path.
" FIXME: update to not dep on coreutils?
inoremap <C-F>
    \ <C-O>:call util#SysR('', 'ftree '. expand('%:p:h')
        \ .'\| xargs -r realpath --relative-to='.
        \ expand('%:p:h') .'\| tr -d \\n')
    \ ->fnameescape()
    \ ->M('norm a')
    \ ->execute()<cr>

" Don't select first autocomplete item, follow typing.
set completeopt=longest,menuone,preview

" Use generic omnicompletion if something more specific isn't already set
if has("autocmd") && exists("+omnifunc")
    au Filetype *
        \ if &omnifunc == "" | setl omnifunc=syntaxcomplete#Complete | endif
endif

" Fuzzy-find files under the current directory and open in window/split/tab etc.
fu! FzyFind(cword = 0)
    return util#SysR('', "ffind . '(' -type f -o -type l ')' -print \| fzy".
        \ (a:cword ? ' -q '. expand('<cword>') : ''))
endfu
nn <leader>ff :call FzyFind() ->M('edit ') ->execute()<cr>
nn <leader>ft :call FzyFind() ->M('tabe ') ->execute()<cr>
nn <leader>fh :call FzyFind() ->M('aboveleft vsplit ') ->execute()<cr>
nn <leader>fl :call FzyFind() ->M('belowright vsplit ') ->execute()<cr>
nn <leader>fj :call FzyFind() ->M('belowright split ') ->execute()<cr>
nn <leader>fk :call FzyFind() ->M('aboveleft split ') ->execute()<cr>
" ...use the word under the cursor as a starting query.
nn <leader>fwf :call FzyFind(1) ->M('edit ') ->execute()<cr>
nn <leader>fwt :call FzyFind(1) ->M('tabe ') ->execute()<cr>
nn <leader>fwh :call FzyFind(1) ->M('aboveleft vsplit ') ->execute()<cr>
nn <leader>fwl :call FzyFind(1) ->M('belowright vsplit ') ->execute()<cr>
nn <leader>fwj :call FzyFind(1) ->M('belowright split ') ->execute()<cr>
nn <leader>fwk :call FzyFind(1) ->M('aboveleft split ') ->execute()<cr>

" }}}
" Window Layout {{{

set encoding=utf-8
set relativenumber              "rnu:   show line numbers relative to the current line; <leader>u to toggle
set signcolumn=yes              "scl:   always show the sign column so it doesn't flap on and off
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
set notitle                     "       don't update xterm (or tmux pane) titles

if &columns < 88
    " If we can't fit at least 80-cols, don't display these screen hogs
    set nonumber
    set foldcolumn=0
    set signcolumn=auto
endif

" Maybe return a string if the first arg is not empty.
fu! M(x, y)
    return a:x == '' ? '' : a:y . a:x
endfu
fu! W(x, y)
    return a:x == '' ? '' : a:x . a:y
endfu

" If we have multiple files open with the same name then also include the
" immdiate parent. (Shakes fist at Redux.)
fu! Nm(fname)
    let l:fpath = expand(a:fname)
    let l:fname = fnamemodify(l:fpath, ':t')

    if l:fpath == '' || l:fpath == l:fname
        return l:fpath
    endif

    let l:similar_list = getwininfo()
        \ ->map({i, x -> bufname(x.bufnr)})
        \ ->filter({i, x -> fnamemodify(x, ':t') == l:fname})

    return len(l:similar_list) == 1 ? l:fname : l:fpath
        \ ->fnamemodify(':h')
        \ ->fnamemodify(':t')
        \ ->{y -> [y, l:fname]}()
        \ ->join('/')
endfu

" Slight variant of standard statusline with 'ruler', file infos, and alt file.
set statusline=%{Nm('%')}\ %<%{M(Nm('#'),'#')}\
    \ %h%m%r%w\ %y\ %{&fileencoding},%{&fileformat}\
    \ %q%=\ %-14.(%l,%c%V%)\ %P

" Arrange Vim windows in tmux-esque layouts. Keeps the current buffer focused.
fu! MainVert()
    let l:winids = win_findbuf(bufnr('%'))
    windo wincmd K
    call win_gotoid(l:winids[0])
    wincmd H
endfu
fu! MainHorz()
    let l:winids = win_findbuf(bufnr('%'))
    windo wincmd H
    call win_gotoid(l:winids[0])
    wincmd K
endfu

" Toggle folds and line wrapping in all windows.
com! AllNofold windo norm zi
com! AllNowrap windo :set nowrap!<bar>:set nowrap?

" Open a new tab of the current buffer and cursor position ("tmux-esque zoom")
nmap <leader>zz :exe 'tabnew +'. line('.') .' %'<cr>

" }}}
" Multi-buffer/window/tab editing {{{

set showtabline=1               " Display the tabbar if there are multiple tabs. Use :tab ball or invoke Vim with -p
set hidden                      " Allows opening a new buffer in place of an existing one without first saving the existing one

" Replace the current window from open buffers:
nn <leader>bb
    \ :redir => _redir \| silent ls \| redir END
    \ \|call util#SysR(_redir, 'fzy -p "Buffers > "')
    \ ->matchstr('[0-9]\+') ->M('b ') ->execute()<cr>

" Use a fuzzy-finder to unload loaded buffers.
com! Delbuf redir => _redir | silent ls | redir END
    \ | call util#SysR(_redir, 'fzy')
    \ ->matchstr('[0-9]\+') ->M('bw ') ->execute()

" When restoring a hidden buffer Vim doesn't always keep the same view (like
" when your view shows beyond the end of the file). (Vim tip 1375)
if ! &diff
    au BufLeave * let b:winview = winsaveview()
    au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif

" Always load the Cfilter/Lfilter commands plugin
packadd cfilter

" Use a fuzzy-finder to switch betweeen quickfix/location-list history entries.
map <F3>
    \ :redir => _redir \| silent chistory \| redir END
    \ \|:call util#SysR(_redir, 'fzy')
    \ ->matchstr('[0-9]\+') ->W('chistory') ->execute()<cr>

map <F4>
    \ :redir => _redir \| silent lhistory \| redir END
    \ \|:call util#SysR(_redir, 'fzy')
    \ ->matchstr('[0-9]\+') ->W('lhistory') ->execute()<cr>

" Shortcuts for working with quickfix/location lists
nmap <silent>]q :cnext<cr>
nmap <silent>[q :cprev<cr>
nmap <silent>[Q :cfirst<cr>
nmap <silent>]Q :clast<cr>
nmap <silent>]l :lnext<cr>
nmap <silent>[l :lprev<cr>
nmap <silent>[L :lfirst<cr>
nmap <silent>]L :llast<cr>

" Toggle the quickfix and location list windows.
com! Toggleqf
    \ call getwininfo()
    \ ->filter({i, x -> x.quickfix && !x.loclist}) ->len()
    \ ->{x -> x ? ':cclose' : ':botright copen | :wincmd p'}()
    \ ->execute()

com! Togglell
    \ call getwininfo()
    \ ->filter({i, v -> bufnr('%') ==
        \ get(v.variables, 'quickfix_title', '_gndn') ->bufnr()})
    \ ->{x -> len(x) > 0 ? ':lclose' : ':lopen | :wincmd p'}()
    \ ->execute()

map <F1> :Toggleqf<cr>
map <F2> :Togglell<cr>

" Open all files referenced in the quickfix list as args.
" Sometimes you just want to step through the files and not all the changes.
com! Qf2Arg call getqflist()
    \ ->filter({i, x -> bufname(x.bufnr) != ''})
    \ ->sort()
    \ ->uniq()
    \ ->map({i, x -> execute('$argadd #'. x.bufnr)})

" Fuzzy-find and edit an entry in the quickfix list.
" FIXME: is 'q' a good prefix for this? what about the location list? do I even use this?
nmap <leader>qf
    \ :call getqflist() ->map({i, x -> bufname(x.bufnr)}) ->sort() ->uniq()
    \ ->util#SysR('fzy -p "Quickfix > "') ->M('e ') ->execute()<cr>

" Toggle diff view on the left, center, or right windows
nmap <silent> <leader>dl :call difftoggle#DiffToggle(1)<cr>
nmap <silent> <leader>dm :call difftoggle#DiffToggle(2)<cr>
nmap <silent> <leader>dr :call difftoggle#DiffToggle(3)<cr>
" Refresh the diff
nmap <silent> <leader>du :diffupdate<cr>
" Toggle ignoring whitespace
nmap <silent> <leader>dw :call iwhitetoggle#IwhiteToggle()<CR>

" grep for conflict markers and add to quickfix list.
com! FindConflicts grep '^<<<<<' %

" Use a (usually) better diff algorithm.
set diffopt+=algorithm:patience
set diffopt+=indent-heuristic

" Alias for ctrl-^ using leader since some terminal emulators consume that
" escape sequence. (Terimal.app on OSX and WSL on Windows.)
nmap <silent> <leader>6 <c-^><cr>

" Also look for the tags file inside the Git directory.
set tags+=.git/tags;

" Fuzzy-find entries in Vim's help files.
" A much faster alternative to :help <char><tab><tab><tab>
" TODO: add third-party 'someplugin/doc/tag' files too...
com! Helpsearch
    \ call readfile($VIMRUNTIME .'/doc/tags')
    \ ->util#SysR('fzy') ->matchstr('[^\t]\+')
    \ ->M('help ') ->execute()

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

" Grey-out the statusbar non-current windows.
au ColorScheme * hi StatusLineNC term=reverse cterm=bold ctermbg=8

" A nice, minimalistic tabline.
au ColorScheme * hi TabLine cterm=bold,underline ctermfg=8 ctermbg=none
au ColorScheme * hi TabLineSel cterm=bold ctermfg=0 ctermbg=7
au ColorScheme * hi TabLineFill cterm=bold ctermbg=none

" Makes the current line stand out with bold and in the numberline
au ColorScheme * hi CursorLine cterm=bold
au ColorScheme * hi LineNr cterm=bold ctermfg=0 ctermbg=none
au ColorScheme * hi CursorLineNr cterm=none

" Set the ColorColumn for toggling via set list.
au ColorScheme * hi ColorColumn ctermbg=7

" Reverse for visual selection is too noisy and not usually legible so just
" disable highlighting inside the selection.
au ColorScheme * hi Visual cterm=bold ctermfg=7 ctermbg=8

" Show search matches in simple reverse.
au ColorScheme * hi Search cterm=reverse ctermfg=none ctermbg=none

" Match the Sign column to the number column
au ColorScheme * hi SignColumn cterm=bold ctermfg=0 ctermbg=none

" Shorten the timeout when looking for a paren match to highlight
let g:matchparen_insert_timeout = 5
set synmaxcol=500               " Stop syntax highlighting on very long lines

" Don't distinguish between delete, add, and change using bright colors. The
" type of change is obvious -- add and delete appear opposite filler markers,
" and changed lines have the changed portion highlighted.
au VimEnter,ColorScheme * hi DiffAdd ctermbg=0
au VimEnter,ColorScheme * hi DiffDelete ctermbg=0
au VimEnter,ColorScheme * hi DiffChange ctermbg=0
" There are two ways to guarantee legibility: force a single foreground color
" against a non-contrasting background color; use reverse foreground colors.
" The drawback of using reverse is there is no consistent color to highlight
" the changes, but reverse is still fairly easy to spot.
au VimEnter,ColorScheme * hi DiffText cterm=reverse ctermbg=none

syntax enable
colorscheme desert
set background=dark

" Add MatchN highlights for highlighting arbitrary text matches legibly.
call map(range(1, 9), {k, v ->
    \ execute(printf('hi Match%s cterm=bold,reverse ctermfg=%s', k + 1, v))})

" }}}
" Printing {{{

" Shows line numbers and adjusts the left margin not to be ridiculous
set printoptions=number:y,left:5pc
set printfont=Monaco:h8         " face-type (not size) ignored in PostScript output :-(
set printencoding=utf-8

" }}}
" Named macros {{{
"   Gives an auto-complete-able name to macros. This is an alternative to
"   having to create key bindings for every little thing. Especially nice for
"   macros that aren't used very often. Runs the macro on each line in a range.
"
"   Usage: record a macro as normal, open an ftplugin or .vimrc and paste the
"   macro, assign that to a single-quoted string (or double-quoted if you want
"   to replace non-printable chars with printable chars (see :norm)), then
"   invoke qq and press tab to cycle through available macro variables.

fu! QQ(varname)
    exe "norm ". a:varname
endfu
com -nargs=1 -range -complete=var QQ <line1>,<line2>call QQ(<args>)
nmap <leader>qq :QQ _
vmap <leader>qq :QQ _

let _uppercase_word = 'gUw'

" }}}
" Plugin settings {{{

" Don't remember register contents between sessions.
set viminfo+=<0

" I stopped using modelines and they can be a security risk, best to disable.
set nomodeline
set modelines=0

" Make mapleader default explicit
let mapleader = '\'

" Disable netrw.
let loaded_netrwPlugin = 1

""" Fuzzy-finder file explorer (of sorts).
nmap <silent> -
    \ :call util#SysR('', 'ftree '. expand('%:p:h') .'\| tr -d \\n')
    \ ->fnameescape()
    \ ->{x -> x == ''
    \     ? ''
    \     : isdirectory(x) ? 'lcd '. x : 'edit '. x
    \ }()
    \ ->execute()<cr><bar>:pwd<cr>

""" Make a buffer into a scratch buffer:
com! Scratch call scratch#Scratch()

""" Diff unstaged changes.
com! Gdiff :call stagediff#StageDiff()
com! Gblame :55vnew
    \| :call scratch#Scratch()
    \| :exe 'r !git blame -c --date=relative -- '. fnamemodify(expand('#'), ':~:.')
    \| 1delete
    \| :wincmd p
    \| :windo setl nofoldenable nowrap scrollbind
    \| :syncbind

""" Surround a visual selection of opfunc movement with characters.
" E.g., to surround with parens: \s(iw
" TODO: Is this really better than: c<motion>"<C-r><C-o>""<Esc>
nmap <expr> <leader>s( opfuncwrapper#WrapOpfunc('surround#Surround', 1, '(')
nmap <expr> <leader>s[ opfuncwrapper#WrapOpfunc('surround#Surround', 1, '[')
nmap <expr> <leader>s{ opfuncwrapper#WrapOpfunc('surround#Surround', 1, '{')
nmap <expr> <leader>s< opfuncwrapper#WrapOpfunc('surround#Surround', 1, '<')
nmap <expr> <leader>s" opfuncwrapper#WrapOpfunc('surround#Surround', 1, '"')
nmap <expr> <leader>s' opfuncwrapper#WrapOpfunc('surround#Surround', 1, "'")
nmap <expr> <leader>s` opfuncwrapper#WrapOpfunc('surround#Surround', 1, '`')
nmap <expr> <leader>ss opfuncwrapper#WrapOpfunc('surround#Surround', 1,
    \input("Surround with what chars? "))
vmap <silent> <leader>s( :<C-U>call 
    \opfuncwrapper#WrapOpfunc('surround#Surround', 0, '(')<cr>

""" Change Case mappings
let g:caser_prefix = mapleader .'w'

""" MRU mappings
" Fuzzy-find and open a file from the most-recently-used buffer list.
nnoremap <leader>fe :call copy(v:oldfiles)
    \ ->map({idx, val -> {'idx': idx + 1, 'path': val}})
    \ ->filter({idx, val -> filereadable(expand(val['path']))
        \ && val['path'] !~ '__Tagbar__'
        \ && val['path'] !~ '__Gundo_'
        \ && val['path'] !~ '.git/'
        \ && val['path'] !~ 'vim/vim81/doc/'
        \ && val['path'] !~ '/dev/fd'
        \ && val['path'] !~ '/var/folders'
    \ })
    \ ->map({idx, val -> val.idx ."\t". val.path})[:20]
    \ ->util#SysR('fzy') ->matchstr('[0-9]\+')
    \ ->M('e #<') ->execute()<cr>

""" Diff two registers
com! -nargs=* DiffRegs call diffregs#DiffRegsFunc(<f-args>)

""" Join and split items based on a delimeter
nmap <expr> <leader>js, opfuncwrapper#WrapOpfunc('joinsplit#SplitItems', 1, ', ')
nmap <expr> <leader>jss opfuncwrapper#WrapOpfunc('joinsplit#SplitItems', 1,
    \input("Split on what chars? ", ", "))
nmap <expr> <leader>jj, opfuncwrapper#WrapOpfunc('joinsplit#JoinItems', 1, ', ')
nmap <expr> <leader>jjj opfuncwrapper#WrapOpfunc('joinsplit#JoinItems', 1,
    \input("Join on what chars? ", ", "))

""" Fold everything _except_ a given range of lines
nmap <expr> <leader>zf opfuncwrapper#WrapOpfunc('foldaround#FoldAround', 1)
vmap <silent> <leader>zf :<C-U>call
    \ opfuncwrapper#WrapOpfunc('foldaround#FoldAround', 0)<cr>

""" Enable builtin matchit plugin
runtime macros/matchit.vim

""" Enable builtin manpage viewer plugin
runtime ftplugin/man.vim
let g:ft_man_no_sect_fallback = 1
let g:ft_man_folding_enable = 1

""" undotree settings
nnoremap <F6> :UndotreeToggle<cr>

""" ale settings
let g:ale_set_highlights = 0
let g:ale_set_signs = 0
let g:ale_echo_cursor = 0

nmap <silent> <leader>fg :ALEFix<cr>
nmap <silent> <leader>fm :call ale#Lint()<cr>

""" Tagbar plugin settings
map <F5> :TagbarToggle<cr>
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_iconchars = ['+', '-']
let g:tagbar_show_linenumbers = -1

" See .md files as markdown instead of modula-2.
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

""" Disable concealing for vim-json
let g:vim_json_syntax_conceal = 0

""" Autocommands for when to place signs
au BufReadPost * call signs#GitChanges()
au BufWritePost * call signs#GitChanges()
au ShellCmdPost * call signs#GitChanges()

call util#StartQfWatchers()
au User Llchanged call signs#Loclist()
au User Qfchanged call signs#Qflist()

""" Mapping to call DetectIndent
nmap <silent> <leader>i :1verbose DetectIndent<cr>

""" Jqplay Settings
let g:jqplay = {
    \ 'opts': '-r',
    \ 'autocmds': ['TextChanged', 'TextChangedI']
\ }

au FileType json
    \ if bufname('%')[:11] ==# 'jq-output://' | syntax clear | endif

""" vimux
com! Makevimux au BufWritePost <buffer> call VimuxRunCommand(" clear; make")

" }}}
" EOF
