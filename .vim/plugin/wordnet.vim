" wordnet.vim
" By Tim Harper (http://tim.theenchanter.com/)
"
" OVERVIEW:
" Easily look up the definition of the word under your cursor via wordnet
" (http://wordnet.princeton.edu/). Definition is shown in a new region, with
" syntax highlighting for easier reading.
"
" INSTRUCTIONS:
" 1) Configure your wordnet path, if it's in a non-standard path (in your
" vimrc)
" let g:wordnet_path = "/usr/local/WordNet-3.0/bin/"
"
" 2) highlight or put your cursor over a word, and:
" <Leader>wnd - Define the word
" <Leader>wnb - Launch the wordnet browser for the word.

command! -nargs=+ Wordnet call WordNetOverviews("<args>")
command! -nargs=+ Wn call WordNetOverviews("<args>")

noremap  <Leader>wnd "wyiw:call WordNetOverviews(@w)<CR>
noremap  <Leader>wnb "wyiw:call WordNetBrowse(@w)<CR>
let s:wordnet_buffer_id = -1

if !exists('g:wordnet_path')
  let g:wordnet_path = ""
endif

function! WordNetBrowse (word)
  call system(g:wordnet_path . "wnb " . a:word)
endfunction

function! WordNetOverviews (word)
  let definition = system(g:wordnet_path . "wn " . a:word . " -over")
  if definition == ""
    let definition = "Word not found: " . a:word
  endif
  call s:WordNetOpenWindow(definition)
endfunction

function! s:WordNetOpenWindow (text)
  " If the buffer is visible
  if bufwinnr("__WordNet__") > -1
    " switch to it
    exec bufwinnr("__WordNet__") . "wincmd w"
    hide
  endif

  if bufnr("__WordNet__") > -1
    exec bufnr("__WordNet__") . "bdelete!"
  endif

  exec 'silent! keepalt botright 20split'
  exec ":e __WordNet__"
  let s:wordnet_buffer_id = bufnr('%')

  call append("^", split(a:text, "\n"))
  exec 0
  " Mark the buffer as scratch
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nonumber
  setlocal nobuflisted
  setlocal readonly
  setlocal nomodifiable

  mapclear <buffer>
  syn match overviewHeader      /^Overview of .\+/
  syn match definitionEntry  /\v^[0-9]+\. .+$/ contains=numberedList,word
  syn match numberedList  /\v^[0-9]+\. / contained
  syn match word  /\v([0-9]+\.[0-9\(\) ]*)@<=[^-]+/ contained
  hi link overviewHeader Title
  hi link numberedList Operator
  hi def word term=bold cterm=bold gui=bold
endfunction
