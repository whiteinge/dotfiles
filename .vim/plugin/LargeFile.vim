" LargeFile: Sets up an autocmd to make editing large files work with celerity
"   Author:		Charles E. Campbell, Jr.
"   Date:		May 24, 2007
"   Version:	3
" GetLatestVimScripts: 1506 1 LargeFile.vim
" \| echomsg 'f='.f.' getfsize(f)='.getfsize(f).' g:LargeFile='.g:LargeFile.'M'

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_LargeFile") || &cp
 finish
endif
let g:loaded_LargeFile = "v3"
let s:keepcpo          = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Commands: {{{1
com! Unlarge call s:Unlarge()

" ---------------------------------------------------------------------
"  Options: {{{1
if !exists("g:LargeFile")
 let g:LargeFile= 20	" in megabytes
endif

" ---------------------------------------------------------------------
"  LargeFile Autocmd: {{{1
" for large files: turns undo, syntax highlighting, undo off etc
" (based on vimtip#611)
augroup LargeFile
 au!
 au BufReadPre *
 \  let f=expand("<afile>")
 \| if getfsize(f) >= g:LargeFile*1024*1024 || getfsize(f) <= -2
 \|  let b:eikeep = &ei
 \|  let b:ulkeep = &ul
 \|  let b:bhkeep = &bh
 \|  let b:fdmkeep= &fdm
 \|  let b:swfkeep= &swf
 \|  set ei=FileType
 \|  setlocal noswf bh=unload fdm=manual
 \|  let f=escape(substitute(f,'\','/','g'),' ')
 \|  exe "au LargeFile BufEnter ".f." set ul=-1"
 \|  exe "au LargeFile BufLeave ".f." let &ul=".b:ulkeep."|set ei=".b:eikeep
 \|  exe "au LargeFile BufUnload ".f." au! LargeFile * ". f
 \|  echomsg "***note*** handling a large file"
 \| endif
 au BufReadPost *
 \  if &ch < 2 && getfsize(expand("<afile>")) >= g:LargeFile*1024*1024
 \|  echomsg "***note*** handling a large file"
 \| endif
augroup END

" ---------------------------------------------------------------------
" s:Unlarge: this function will undo what the LargeFile autocmd does {{{2
fun! s:Unlarge()
"  call Dfunc("s:Unlarge()")
  if exists("b:eikeep") |let &ei  = b:eikeep |endif
  if exists("b:ulkeep") |let &ul  = b:ulkeep |endif
  if exists("b:bhkeep") |let &bh  = b:bhkeep |endif
  if exists("b:fdmkeep")|let &fdm = b:fdmkeep|endif
  if exists("b:swfkeep")|let &swf = b:swfkeep|endif
  doau FileType
"  call Dret("s:Unlarge")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
