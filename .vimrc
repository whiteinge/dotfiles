" Best Goddamn vimrc in the whole world.
" Author: Seth House <seth@eseth.com>
" For more information type :help followed by the command.

set nocompatible                "cp:    turns off strct vi compatibility

" Search {{{

set incsearch                   "is:    automatically begins searching as you type
set ignorecase                  "ic:    ignores case when pattern matching
set smartcase                   "scs:   ignores ignorecase when pattern contains uppercase characters
set hlsearch                    "hls:   highlights search results
" Use leader-n to unhighlight search results in normal mode:
nmap <silent> <leader>n :silent noh<CR>
" Display the number of matches for the last search
nmap <leader># :%s:/::gn<CR>
" Restore case-sensitivity for jumping to tags (set ic disables it)
map <silent> <c-]> :set noic<cr>g<c-]><silent>:set ic<cr>

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
set cinoptions=l1,c4,(s,U1,w1,m1,j1,J1
set cinwords=if,elif,else,for,while,try,except,finally,def,class

set expandtab                   "et:    uses spaces instead of tab characters
set smarttab                    "sta:   helps with backspacing because of expandtab
set softtabstop=4               "ts:    number of spaces that a tab counts for
set shiftwidth=4                "sw:    number of spaces to use for autoindent
set shiftround                  "sr:    rounds indent to a multiple of shiftwidth

set nojoinspaces                "nojs:  prevents inserting two spaces after punctuation on a join (it's not 1990 anymore)
set lazyredraw                  "lz:    will not redraw the screen while running macros (goes faster)
set pastetoggle=<F5>            "pt:    useful so auto-indenting doesn't mess up code when pasting

set virtualedit=block           "ve:    let cursor move past the last char in <C-v> mode
set nostartofline               "sol:   avoid moving cursor to BOL when jumping around

set cryptmethod=blowfish        "cm:    use (much) stronger blowfish encryption

" Fix for legacy vi inconsistency
map Y y$

" Allow undoing insert-mode ctrl-u and ctrl-w
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" Add a line without changing position or leaving mode
map <leader>o :set paste<CR>m`o<Esc>``:set nopaste<CR>
map <leader>O :set paste<CR>m`O<Esc>``:set nopaste<CR>

" A shortcut to show the numbered register contents
map <F2> :reg "0123456789-*+:/<CR>

set colorcolumn=80              "cc:    draw a visual line down the 80th column

" Toggle between line numbers and relative line numbers
nmap <silent><F10> :exe "set " . (&relativenumber == 1 ? "" : "relative") . "number"<cr>

"lcs:   displays tabs with :set list & displays when a line runs off-screen
set listchars=tab:>-,trail:\ ,precedes:<,extends:>

" Toggle spell-checking
map <silent> <F8> :set nospell!<CR>:set nospell?<CR>

" Maps Omnicompletion to CTRL-space since ctrl-x ctrl-o is for Emacs-style RSI
inoremap <Nul> <C-x><C-o>

" don't select first item, follow typing in autocomplete
set completeopt=longest,menuone,preview

" CD to the path of the current file.
map <leader>cd :cd %:p:h<CR>

" Highlight problem lines: more than 80 chars, trailing spaces, only whitespace
" Toggle with \l
nnoremap <silent> <Leader>l
      \ :set nolist!<CR>:set nolist?<CR>
      \ :if exists('w:long_line_match') <Bar>
      \   silent! call matchdelete(w:long_line_match) <Bar>
      \   unlet w:long_line_match <Bar>
      \ elseif &textwidth > 0 <Bar>
      \   let w:long_line_match = matchadd('ErrorMsg', '\%>'.&tw.'v.\+', -1) <Bar>
      \ else <Bar>
      \   let w:long_line_match = matchadd('ErrorMsg', '\%>80v.\+', -1) <Bar>
      \ endif<CR>

" Find merge conflict markers
map <Leader>fc /\v^[<=>]{7}( .*\|$)<CR>

set dictionary=spell        " dict:     complete words from the spelling dict (when spell is on)
" set thesaurus             " tsr:      complete words from a thesaurus

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

set switchbuf=usetab            "swb:   Jumps to first tab or window that contains specified buffer instead of duplicating an open window
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
nmap <silent> <leader>dc :call DiffToggle(2)<cr>
nmap <silent> <leader>dr :call DiffToggle(3)<cr>


" }}}
" X11 Integration {{{
" (I.e.: don't do any automatic integration, please :)

set mouse=                      "       Disable mouse control for console Vim (very annoying)
set clipboard=                  "       Disable automatic X11 clipboard crossover

" }}}
" Color {{{
"   All coloring options are for the non-GUI Vim (see :help cterm-colors).

color desert

" Make listchars (much) more noticable.
hi SpecialKey ctermfg=7 ctermbg=1

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

" Darkens the status line for non-active windows.
au BufEnter * hi User9 ctermfg=7

" A nice, minimalistic tabline.
hi TabLine cterm=bold,underline ctermfg=8 ctermbg=none
hi TabLineSel cterm=bold ctermfg=0 ctermbg=7
hi TabLineFill cterm=bold ctermbg=none

" Black ColorColumn to not catch the eye more than is necessary
hi ColorColumn ctermbg=0

" Makes current line yellow against gray line numbers
hi LineNr cterm=bold ctermfg=0 ctermbg=none

" Refresh busted syntax highlighting (this happens too often)
noremap <F11> <Esc>:syntax sync fromstart<CR>

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
let NERDTreeDirArrows=0
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

" Commenting with opfunc {{{
" http://vim.wikia.com/wiki/Commenting_with_opfunc
" \c to comment or \C uncomment, then press a regular Vim movement command
" Temporarily set comment chars with :let b:comment='#---'

function! CommentMark(docomment, a, b)
    if !exists('b:comment')
        let b:comment = CommentStr() . ' '
    endif
    if a:docomment
        exe "normal! '" . a:a . "_\<C-V>'" . a:b . 'I' . b:comment
    else
        exe "'".a:a.",'".a:b . 's/^\(\s*\)' . escape(b:comment,'/') . '/\1/e'
    endif
endfunction

" Comment lines in marks set by g@ operator.
function! DoCommentOp(type)
    call CommentMark(1, '[', ']')
endfunction

" Uncomment lines in marks set by g@ operator.
function! UnCommentOp(type)
    call CommentMark(0, '[', ']')
endfunction

" Return string used to comment line for current filetype.
function! CommentStr()
    if &ft == 'java' || &ft == 'javascript'
        return '//'
    elseif &ft == 'vim'
        return '"'
    elseif &ft == 'rst'
        return '..'
    else
        return '#'
    endif
endfunction

nnoremap <Leader>c <Esc>:set opfunc=DoCommentOp<CR>g@
nnoremap <Leader>C <Esc>:set opfunc=UnCommentOp<CR>g@
vnoremap <Leader>c <Esc>:call CommentMark(1,'<','>')<CR>
vnoremap <Leader>C <Esc>:call CommentMark(0,'<','>')<CR>

" }}}
" Surrounding text with opfunc {{{

" Adds a "surround" operator for use with text objects.
" http://stackoverflow.com/a/8998136
" Usage:
"       Surround a sentence with quotes with:  sis"
"       Specify different start and end surround characters by separating them
"       with whitespace: siw<b> </b>
nnoremap <silent> s :set opfunc=Surround<cr>g@
vnoremap <silent> s :<c-u>call Surround(visualmode(), 1)<cr>
function! Surround(vt, ...)
    let s = input("Surround with: ")
    let si = split(s, " ")
    let sleft = si[-1]
    let sright = si[0]
    if s =~ "\<esc>" || s =~ "\<c-c>"
        return
    endif
    " FIXME: if s contains a space, split and surround with left/right chars
    let [sl, sc] = getpos(a:0 ? "'<" : "'[")[1:2]
    let [el, ec] = getpos(a:0 ? "'>" : "']")[1:2]
    if a:vt == 'line' || a:vt == 'V'
        call append(el, sleft)
        call append(sl-1, sright)
    elseif a:vt == 'block' || a:vt == "\<c-v>"
        exe sl.','.el 's/\%'.sc.'c\|\%'.ec.'c.\zs/\=s/g|norm!``'
    else
        exe el 's/\%'.ec.'c.\zs/\=sleft/|norm!``'
        exe sl 's/\%'.sc.'c/\=sright/|norm!``'
    endif
endfunction

" }}}
" YankList {{{1
" Is is possbile to store the ten most recent yanks using opfunc (similar to
" the built-in numbered registers)?
" NOTE: work in progress, this is currently non-functional

" noremap <silent> gy :set opfunc=YankList<CR>g@
" vmap <silent> gy :<C-U>call YankList(visualmode(), 1)<CR>
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
" MyStatusLine {{{

" TODO: add a check for screen width and remove the alternate buffer display
" and args of total display for small screen widths.
function! MyStatusLine()
    let s = '%9* %* ' " pad the edges for better vsplit separation
    let s .= '%3*' " User highlighting
    let s .= '%%%n '
    if bufname('') != '' " why is this such a pain in the ass?
        let s .= "%{ pathshorten(fnamemodify(expand('%F'), ':~:.')) }" " short-hand path of of the current buffer
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
    let s .= '%{&fileencoding}' " fileencoding
    let s .= '%*,' " restore normal highlighting
    let s .= '%6*' " User highlighting
    let s .= '%{&fileformat}' " line-ending type
    let s .= '%*' " restore normal highlighting
    let s .= '>'
    let s .= '%a' " (args of total)
    let s .= '%q' " is quickfix or location list
    let s .= '  %9*' " user highlighting
    let s .= '%=' " separate right- from left-aligned
    let s .= '%*' " restore normal highlighting
    let s .= '%7*  ' " user highlighting
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
    let s .= ' %9* %*' " pad the edges for better vsplit separation
    return s
endfunction

set statusline=%!MyStatusLine()

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

" Autocommands, plugin, and file-type-specific settings {{{

" Load Pathogen plugins
call pathogen#infect()

" Auto-set certain options as well as syntax highlighting and indentation
filetype plugin indent on

" Set filetype for Salt sls files
au BufNewFile,BufRead *.sls set ft=sls

" Set filetype for Jinja files
au BufNewFile,BufRead *.jinja* set ft=jinja

" Load omnicompletion for supported filetypes
" fallback to generic completion based on the syntax file
if has("autocmd") && exists("+omnifunc")
    autocmd FileType python set omnifunc=pythoncomplete#Complete
    autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
    autocmd FileType php set omnifunc=phpcomplete#CompletePHP
    autocmd FileType xml set omnifunc=phpcomplete#CompleteXML
    autocmd FileType sql set omnifunc=phpcomplete#CompleteSQL
    autocmd Filetype *
                \   if &omnifunc == "" |
                \           setlocal omnifunc=syntaxcomplete#Complete |
                \   endif
endif

" Not sure why the cron filetype isn't catching this...
au FileType crontab set backupcopy=yes

" Enables :make to compile, or validate, certain filetypes
" (use :cn & :cp to jump between errors)
au FileType xml,xslt compiler xmllint
au FileType html compiler tidy
au FileType java compiler javac

" Add PYTHONPATH to Vim path to enable 'gf' (also works when in a virtualenv)
if has('python')
py << EOL
import vim, os, site, sys
basedir = os.environ.get('VIRTUAL_ENV', '')
if basedir:
    pyver = 'python{0}'.format('.'.join(sys.version.split('.')[:2]))
    libdir = os.path.join(basedir, 'lib', pyver, 'site-packages')
    site.addsitedir(libdir)

paths = [i.replace(' ', r'\ ') for i in sys.path if os.path.isdir(i)]
vim.command(r'set path+={0}'.format(','.join(paths)))
EOL
endif

" Shortcut to invoke wordnet
noremap  <F7> "wyiw:call WordNetOverviews(@w)<CR>

" Set keywordprg for certain filetypes
au FileType python set keywordprg=pydoc

" Configure Python files to use pylint on :make
" (supports error type and multiline errors)
au FileType python set makeprg=pylint\ -E\ -r\ n\ -f\ parseable\ %:p
au FileType python set efm=%A%f:%l:\ [%t%.%#]\ %m,%Z%p^^,%-C%.%#

" Set pyflakes to keep the clist available for regular use
let g:pyflakes_use_quickfix = 0

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

" Automatically open Git diff when editing a gitcommit
au FileType gitcommit DiffGitCached | set nowrap | wincmd p

" Mapping to invoke Gundo
nnoremap <F5> :GundoToggle<CR>

" Syntastic settings
let g:syntastic_enable_highlighting = 0
nmap <silent> <leader>y :SyntasticCheck<cr>

" Tagbar plugin settings
map <F3> :TagbarToggle<cr>
let g:tagbar_sort = 0
let g:tagbar_compact = 1
let g:tagbar_autoshowtag = 1
let g:tagbar_width = 25
let g:tagbar_iconchars = ['+', '-']

" ft-specific tagbar settings
let g:tagbar_type_python = {
    \ 'kinds' : [
        \ 'c:classes',
        \ 'f:functions',
        \ 'm:class members',
        \ 'v:variables:1',
        \ 'i:imports:1'
    \ ]
\ }

let g:tagbar_type_rst = {
    \ 'ctagsbin' : 'rst2ctags',
    \ 'ctagsargs' : '--taglist',
    \ 'kinds' : [
        \ 's:Sections',
        \ 'i:Images',
    \ ],
\ }

let g:tagbar_type_mediawiki = {
    \ 'ctagstype' : 'mediawiki',
    \ 'kinds' : [
        \ 'h:Headings',
    \ ],
\ }

let g:tagbar_type_tex = {
    \ 'ctagstype' : 'latex',
    \ 'kinds'     : [
        \ 's:sections',
        \ 'g:graphics:0:0',
        \ 'l:labels',
        \ 'r:refs:1:0',
        \ 'p:pagerefs:1:0'
    \ ],
    \ 'sort'    : 0,
\ }

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


" Makes the current buffer a scratch buffer
function! Scratch()
    set buftype=nofile
    set bufhidden=delete
    set noswapfile
endfunction
noremap <silent> ,s :exe Scratch()<CR>

" Outputs a small warning when opening a file that contains tab characters
function! WarnTabs()
    let save_cursor = getpos('.')
    if searchpos('\t') != [0,0]
        echohl WarningMsg |
        \ echo "Warning, this file contains tabs." |
        \ echohl None
    endif
    call setpos('.', save_cursor)
endfunction
autocmd BufReadPost * call WarnTabs()

" }}}

" eof
" vim:ft=vim:fdm=marker:ff=unix:nowrap:tabstop=4:shiftwidth=4:softtabstop=4:smarttab:shiftround:expandtab
