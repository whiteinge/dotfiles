" DrawIt.vim: a simple way to draw things in Vim
"
" Maintainer:	Charles E. Campbell, Jr.
" Authors:	Charles E. Campbell, Jr. <NdrOchipS@PcampbellAfamily.Mbiz> - NOSPAM
"   		Sylvain Viart (molo@multimania.com)
" Version:	10
" Date:		Jun 12, 2008
"
" Quick Setup: {{{1
"              tar -oxvf DrawIt.tar
"              Should put DrawItPlugin.vim in your .vim/plugin directory,
"                     put DrawIt.vim       in your .vim/autoload directory
"                     put DrawIt.txt       in your .vim/doc directory.
"             Then, use \di to start DrawIt,
"                       \ds to stop  Drawit, and
"                       draw by simply moving about using the cursor keys.
"
"             You may also use visual-block mode to select endpoints and
"             draw lines, arrows, and ellipses.
"
" Copyright:    Copyright (C) 1999-2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               DrawIt.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.
"
" Required:		THIS SCRIPT REQUIRES VIM 7.0 (or later) {{{1
" GetLatestVimScripts: 40 1 :AutoInstall: DrawIt.vim
" GetLatestVimScripts: 1066 1 cecutil.vim
"
"  Woe to her who is rebellious and polluted, the oppressing {{{1
"  city! She didn't obey the voice. She didn't receive correction.
"  She didn't trust in Yahweh. She didn't draw near to her God. (Zeph 3:1,2 WEB)

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_DrawIt")
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Script Variables: {{{1
if !exists("s:saveposn_count")
 let s:saveposn_count= 0
endif
let g:loaded_DrawIt= "v10"
"DechoTabOn

" =====================================================================
" DrawIt Functions: (by Charles E. Campbell, Jr.) {{{1
" =====================================================================

" ---------------------------------------------------------------------
" DrawIt#StartDrawIt: this function maps the cursor keys, sets up default {{{2
"              drawing characters, and makes some settings
fun! DrawIt#StartDrawIt()
"  call Dfunc("StartDrawIt()")

  " StartDrawIt: report on [DrawIt] mode {{{3
  if exists("b:dodrawit") && b:dodrawit == 1
   " already in DrawIt mode
    echo "[DrawIt] (already on, use ".((exists("mapleader") && mapleader != "")? mapleader : '\')."ds to stop)"
"   call Dret("StartDrawIt")
   return
  endif
  let b:dodrawit= 1

  " indicate in DrawIt mode
  echo "[DrawIt]"

  " StartDrawIt: turn on mouse {{{3
  if !exists("b:drawit_keep_mouse")
   let b:drawit_keep_mouse= &mouse
  endif
  setlocal mouse=a

  " StartDrawIt: set up DrawIt commands {{{3
  com! -nargs=1 -range SetBrush <line1>,<line2>call DrawIt#SetBrush(<q-args>)
  com! -count Canvas call s:Spacer(line("."),line(".") + <count> - 1,0)

  " StartDrawIt: set up default drawing characters {{{3
  if !exists("b:di_vert")
   let b:di_vert= "|"
  endif
  if !exists("b:di_horiz")
   let b:di_horiz= "-"
  endif
  if !exists("b:di_plus")
   let b:di_plus= "+"
  endif
  if !exists("b:di_upright")  " also downleft
   let b:di_upright= "/"
  endif
  if !exists("b:di_upleft")   " also downright
   let b:di_upleft= "\\"
  endif
  if !exists("b:di_cross")
   let b:di_cross= "X"
  endif
  if !exists("b:di_ellipse")
   let b:di_ellipse= '*'
  endif

  " set up initial DrawIt behavior (as opposed to erase behavior)
  let b:di_erase     = 0

  " StartDrawIt: option recording {{{3
  let b:di_aikeep    = &ai
  let b:di_cinkeep   = &cin
  let b:di_cpokeep   = &cpo
  let b:di_etkeep    = &et
  let b:di_fokeep    = &fo
  let b:di_gdkeep    = &gd
  let b:di_gokeep    = &go
  let b:di_magickeep = &magic
  let b:di_remapkeep = &remap
  let b:di_repkeep   = &report
  let b:di_sikeep    = &si
  let b:di_stakeep   = &sta
  let b:di_vekeep    = &ve
  set cpo&vim
  set nocin noai nosi nogd sta et ve=all report=10000
  set go-=aA
  set fo-=a
  set remap magic

  " StartDrawIt: save and unmap user maps {{{3
  let b:lastdir    = 1
  if exists("mapleader")
   let usermaplead  = mapleader
  else
   let usermaplead  = "\\"
  endif
  call SaveUserMaps("n","","><^v","DrawIt")
  call SaveUserMaps("v",usermaplead,"abeflsy","DrawIt")
  call SaveUserMaps("n",usermaplead,"h><v^","DrawIt")
  call SaveUserMaps("n","","<left>","DrawIt")
  call SaveUserMaps("n","","<right>","DrawIt")
  call SaveUserMaps("n","","<up>","DrawIt")
  call SaveUserMaps("n","","<down>","DrawIt")
  call SaveUserMaps("n","","<left>","DrawIt")
  call SaveUserMaps("n","","<s-right>","DrawIt")
  call SaveUserMaps("n","","<s-up>","DrawIt")
  call SaveUserMaps("n","","<s-down>","DrawIt")
  call SaveUserMaps("n","","<space>","DrawIt")
  call SaveUserMaps("n","","<home>","DrawIt")
  call SaveUserMaps("n","","<end>","DrawIt")
  call SaveUserMaps("n","","<pageup>","DrawIt")
  call SaveUserMaps("n","","<pagedown>","DrawIt")
  call SaveUserMaps("n","","<leftmouse>","DrawIt")
  call SaveUserMaps("n","","<middlemouse>","DrawIt")
  call SaveUserMaps("n","","<rightmouse>","DrawIt")
  call SaveUserMaps("n","","<leftdrag>","DrawIt")
  call SaveUserMaps("n","","<s-leftmouse>","DrawIt")
  call SaveUserMaps("n","","<s-leftdrag>","DrawIt")
  call SaveUserMaps("n","","<s-leftrelease>","DrawIt")
  call SaveUserMaps("n","","<c-leftmouse>","DrawIt")
  call SaveUserMaps("n","","<c-leftdrag>","DrawIt")
  call SaveUserMaps("n","","<c-leftrelease>","DrawIt")
  call SaveUserMaps("n",usermaplead,":pa","DrawIt")
  call SaveUserMaps("n",usermaplead,":pb","DrawIt")
  call SaveUserMaps("n",usermaplead,":pc","DrawIt")
  call SaveUserMaps("n",usermaplead,":pd","DrawIt")
  call SaveUserMaps("n",usermaplead,":pe","DrawIt")
  call SaveUserMaps("n",usermaplead,":pf","DrawIt")
  call SaveUserMaps("n",usermaplead,":pg","DrawIt")
  call SaveUserMaps("n",usermaplead,":ph","DrawIt")
  call SaveUserMaps("n",usermaplead,":pi","DrawIt")
  call SaveUserMaps("n",usermaplead,":pj","DrawIt")
  call SaveUserMaps("n",usermaplead,":pk","DrawIt")
  call SaveUserMaps("n",usermaplead,":pl","DrawIt")
  call SaveUserMaps("n",usermaplead,":pm","DrawIt")
  call SaveUserMaps("n",usermaplead,":pn","DrawIt")
  call SaveUserMaps("n",usermaplead,":po","DrawIt")
  call SaveUserMaps("n",usermaplead,":pp","DrawIt")
  call SaveUserMaps("n",usermaplead,":pq","DrawIt")
  call SaveUserMaps("n",usermaplead,":pr","DrawIt")
  call SaveUserMaps("n",usermaplead,":ps","DrawIt")
  call SaveUserMaps("n",usermaplead,":pt","DrawIt")
  call SaveUserMaps("n",usermaplead,":pu","DrawIt")
  call SaveUserMaps("n",usermaplead,":pv","DrawIt")
  call SaveUserMaps("n",usermaplead,":pw","DrawIt")
  call SaveUserMaps("n",usermaplead,":px","DrawIt")
  call SaveUserMaps("n",usermaplead,":py","DrawIt")
  call SaveUserMaps("n",usermaplead,":pz","DrawIt")
  call SaveUserMaps("n",usermaplead,":ra","DrawIt")
  call SaveUserMaps("n",usermaplead,":rb","DrawIt")
  call SaveUserMaps("n",usermaplead,":rc","DrawIt")
  call SaveUserMaps("n",usermaplead,":rd","DrawIt")
  call SaveUserMaps("n",usermaplead,":re","DrawIt")
  call SaveUserMaps("n",usermaplead,":rf","DrawIt")
  call SaveUserMaps("n",usermaplead,":rg","DrawIt")
  call SaveUserMaps("n",usermaplead,":rh","DrawIt")
  call SaveUserMaps("n",usermaplead,":ri","DrawIt")
  call SaveUserMaps("n",usermaplead,":rj","DrawIt")
  call SaveUserMaps("n",usermaplead,":rk","DrawIt")
  call SaveUserMaps("n",usermaplead,":rl","DrawIt")
  call SaveUserMaps("n",usermaplead,":rm","DrawIt")
  call SaveUserMaps("n",usermaplead,":rn","DrawIt")
  call SaveUserMaps("n",usermaplead,":ro","DrawIt")
  call SaveUserMaps("n",usermaplead,":rp","DrawIt")
  call SaveUserMaps("n",usermaplead,":rq","DrawIt")
  call SaveUserMaps("n",usermaplead,":rr","DrawIt")
  call SaveUserMaps("n",usermaplead,":rs","DrawIt")
  call SaveUserMaps("n",usermaplead,":rt","DrawIt")
  call SaveUserMaps("n",usermaplead,":ru","DrawIt")
  call SaveUserMaps("n",usermaplead,":rv","DrawIt")
  call SaveUserMaps("n",usermaplead,":rw","DrawIt")
  call SaveUserMaps("n",usermaplead,":rx","DrawIt")
  call SaveUserMaps("n",usermaplead,":ry","DrawIt")
  call SaveUserMaps("n",usermaplead,":rz","DrawIt")
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   call SaveUserMaps("i","","<left>","DrawIt")
   call SaveUserMaps("i","","<right>","DrawIt")
   call SaveUserMaps("i","","<up>","DrawIt")
   call SaveUserMaps("i","","<down>","DrawIt")
   call SaveUserMaps("i","","<left>","DrawIt")
   call SaveUserMaps("i","","<s-right>","DrawIt")
   call SaveUserMaps("i","","<s-up>","DrawIt")
   call SaveUserMaps("i","","<s-down>","DrawIt")
   call SaveUserMaps("i","","<home>","DrawIt")
   call SaveUserMaps("i","","<end>","DrawIt")
   call SaveUserMaps("i","","<pageup>","DrawIt")
   call SaveUserMaps("i","","<pagedown>","DrawIt")
   call SaveUserMaps("i","","<leftmouse>","DrawIt")
  endif
  call SaveUserMaps("n","",":\<c-v>","DrawIt")

  " StartDrawIt: DrawIt maps (Charles Campbell) {{{3
  nmap <silent> <left>     :set lz<CR>:silent! call <SID>DrawLeft()<CR>:set nolz<CR>
  nmap <silent> <right>    :set lz<CR>:silent! call <SID>DrawRight()<CR>:set nolz<CR>
  nmap <silent> <up>       :set lz<CR>:silent! call <SID>DrawUp()<CR>:set nolz<CR>
  nmap <silent> <down>     :set lz<CR>:silent! call <SID>DrawDown()<CR>:set nolz<CR>
  nmap <silent> <s-left>   :set lz<CR>:silent! call <SID>MoveLeft()<CR>:set nolz<CR>
  nmap <silent> <s-right>  :set lz<CR>:silent! call <SID>MoveRight()<CR>:set nolz<CR>
  nmap <silent> <s-up>     :set lz<CR>:silent! call <SID>MoveUp()<CR>:set nolz<CR>
  nmap <silent> <s-down>   :set lz<CR>:silent! call <SID>MoveDown()<CR>:set nolz<CR>
  nmap <silent> <space>    :set lz<CR>:silent! call <SID>DrawErase()<CR>:set nolz<CR>
  nmap <silent> >          :set lz<CR>:silent! call <SID>DrawSpace('>',1)<CR>:set nolz<CR>
  nmap <silent> <          :set lz<CR>:silent! call <SID>DrawSpace('<',2)<CR>:set nolz<CR>
  nmap <silent> ^          :set lz<CR>:silent! call <SID>DrawSpace('^',3)<CR>:set nolz<CR>
  nmap <silent> v          :set lz<CR>:silent! call <SID>DrawSpace('v',4)<CR>:set nolz<CR>
  nmap <silent> <home>     :set lz<CR>:silent! call <SID>DrawSlantUpLeft()<CR>:set nolz<CR>
  nmap <silent> <end>      :set lz<CR>:silent! call <SID>DrawSlantDownLeft()<CR>:set nolz<CR>
  nmap <silent> <pageup>   :set lz<CR>:silent! call <SID>DrawSlantUpRight()<CR>:set nolz<CR>
  nmap <silent> <pagedown> :set lz<CR>:silent! call <SID>DrawSlantDownRight()<CR>:set nolz<CR>
  nmap <silent> <Leader>>	:set lz<CR>:silent! call <SID>DrawFatRArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader><	:set lz<CR>:silent! call <SID>DrawFatLArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader>^	:set lz<CR>:silent! call <SID>DrawFatUArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader>v	:set lz<CR>:silent! call <SID>DrawFatDArrow()<CR>:set nolz<CR>
  nmap <silent> <Leader>f  :call <SID>Flood()<cr>

  " StartDrawIt: Set up insertmode maps {{{3
  if exists("g:drawit_insertmode") && g:drawit_insertmode
   imap <buffer> <silent> <left>     <Esc><left>a
   imap <buffer> <silent> <right>    <Esc><right>a
   imap <buffer> <silent> <up>       <Esc><up>a
   imap <buffer> <silent> <down>     <Esc><down>a
   imap <buffer> <silent> <left>   <Esc><left>a
   imap <buffer> <silent> <s-right>  <Esc><s-right>a
   imap <buffer> <silent> <s-up>     <Esc><s-up>a
   imap <buffer> <silent> <s-down>   <Esc><s-down>a
   imap <buffer> <silent> <home>     <Esc><home>a
   imap <buffer> <silent> <end>      <Esc><end>a
   imap <buffer> <silent> <pageup>   <Esc><pageup>a
   imap <buffer> <silent> <pagedown> <Esc><pagedown>a
  endif

  " StartDrawIt: set up drawing mode mappings (Sylvain Viart) {{{3
  nnoremap <buffer> <silent> <c-v>      :call <SID>LeftStart()<CR><c-v>
  vmap     <buffer> <silent> <Leader>a  :<c-u>call <SID>CallBox('Arrow')<CR>
  vmap     <buffer> <silent> <Leader>b  :<c-u>call <SID>CallBox('DrawBox')<cr>
  nmap     <buffer>          <Leader>c  :call <SID>Canvas()<cr>
  vmap     <buffer> <silent> <Leader>l  :<c-u>call <SID>CallBox('DrawPlainLine')<CR>
  vmap     <buffer> <silent> <Leader>s  :<c-u>call <SID>Spacer(line("'<"), line("'>"),0)<cr>

  " StartDrawIt: set up drawing mode mappings (Charles Campbell) {{{3
  " \pa ... \pz : blanks are transparent
  " \ra ... \rz : blanks copy over
  vmap <buffer> <silent> <Leader>e   :<c-u>call <SID>CallBox('DrawEllipse')<CR>
  
  let allreg= "abcdefghijklmnopqrstuvwxyz"
  while strlen(allreg) > 0
   let ireg= strpart(allreg,0,1)
   exe "nmap <buffer> <silent> <Leader>p".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",0)<cr>:set nolz<cr>'
   exe "nmap <buffer> <silent> <Leader>r".ireg.'  :<c-u>set lz<cr>:silent! call <SID>PutBlock("'.ireg.'",1)<cr>:set nolz<cr>'
   let allreg= strpart(allreg,1)
  endwhile

  " StartDrawIt: mouse maps  (Sylvain Viart) {{{3
  " start visual-block with leftmouse
  nnoremap <buffer> <silent> <leftmouse>    <leftmouse>:call <SID>LeftStart()<CR><c-v>
  vnoremap <buffer> <silent> <rightmouse>   <leftmouse>:<c-u>call <SID>RightStart(1)<cr>
  vnoremap <buffer> <silent> <middlemouse>  <leftmouse>:<c-u>call <SID>RightStart(0)<cr>
  vnoremap <buffer> <silent> <c-leftmouse>  <leftmouse>:<c-u>call <SID>CLeftStart()<cr>

  " StartDrawIt: mouse maps (Charles Campbell) {{{3
  " Draw with current brush
  nnoremap <buffer> <silent> <s-leftmouse>  <leftmouse>:call <SID>SLeftStart()<CR><c-v>
  nnoremap <buffer> <silent> <c-leftmouse>  <leftmouse>:call <SID>CLeftStart()<CR><c-v>

 " StartDrawIt: Menu support {{{3
 if has("gui_running") && has("menu") && &go =~ 'm'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt<tab>\\ds				<Leader>ds'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode<tab><space>	<space>'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow<tab>\\a					<Leader>a'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box<tab>\\b						<Leader>b'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone<tab>\\c			<Leader>c'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse<tab>\\e					<Leader>e'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood<tab>\\e					<Leader>f'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line<tab>\\l						<Leader>l'
  exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks<tab>\\s				<Leader>s'
  exe 'silent! unmenu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt'
 endif
" call Dret("StartDrawIt")
endfun

" ---------------------------------------------------------------------
" DrawIt#StopDrawIt: this function unmaps the cursor keys and restores settings {{{2
fun! DrawIt#StopDrawIt()
"  call Dfunc("StopDrawIt()")
 
  " StopDrawIt: report on [DrawIt off] mode {{{3
  if !exists("b:dodrawit")
   echo "[DrawIt off]"
"   call Dret("StopDrawIt")
   return
  endif

  " StopDrawIt: restore mouse {{{3
  if exists("b:drawit_keep_mouse")
   let &mouse= b:drawit_keep_mouse
   unlet b:drawit_keep_mouse
  endif
  unlet b:dodrawit
  echo "[DrawIt off]"

  if exists("b:drawit_canvas_used")
   " StopDrawIt: clean up trailing white space {{{3
   call s:SavePosn()
   silent! %s/\s\+$//e
   unlet b:drawit_canvas_used
   call s:RestorePosn()
  endif

  " StopDrawIt: remove drawit commands {{{3
  delc SetBrush

  " StopDrawIt: insure that erase mode is off {{{3
  " (thanks go to Gary Johnson for this)
  if b:di_erase == 1
  	call s:DrawErase()
  endif

  " StopDrawIt: restore user map(s), if any {{{3
  call RestoreUserMaps("DrawIt")

  " StopDrawIt: restore user's options {{{3
  let &ai     = b:di_aikeep
  let &cin    = b:di_cinkeep
  let &cpo    = b:di_cpokeep
  let &et     = b:di_etkeep
  let &fo     = b:di_fokeep
  let &gd     = b:di_gdkeep
  let &go     = b:di_gokeep
  let &magic  = b:di_magickeep
  let &remap  = b:di_remapkeep
  let &report = b:di_repkeep
  let &si     = b:di_sikeep
  let &sta    = b:di_stakeep
  let &ve     = b:di_vekeep
  unlet b:di_aikeep  
  unlet b:di_cinkeep 
  unlet b:di_cpokeep 
  unlet b:di_etkeep  
  unlet b:di_fokeep  
  unlet b:di_gdkeep  
  unlet b:di_gokeep  
  unlet b:di_magickeep
  unlet b:di_remapkeep
  unlet b:di_repkeep
  unlet b:di_sikeep  
  unlet b:di_stakeep 
  unlet b:di_vekeep  

 " StopDrawIt: DrChip menu support: {{{3
 if has("gui_running") && has("menu") && &go =~ 'm'
  exe 'menu   '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt<tab>\\di		<Leader>di'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Stop\ \ DrawIt'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Toggle\ Erase\ Mode'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Arrow'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Box'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Ellipse'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Flood'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Draw\ Line'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Make\ Blank\ Zone'
  exe 'unmenu '.g:DrChipTopLvlMenu.'DrawIt.Append\ Blanks'
 endif
" call Dret("StopDrawIt")
endfun

" ---------------------------------------------------------------------
" SetDrawIt: this function allows one to change the drawing characters {{{2
fun! SetDrawIt(di_vert,di_horiz,di_plus,di_upleft,di_upright,di_cross,di_ellipse)
"  call Dfunc("SetDrawIt(vert<".a:di_vert."> horiz<".a:di_horiz."> plus<".a:di_plus."> upleft<".a:di_upleft."> upright<".a:di_upright."> cross<".a:di_cross."> ellipse<".a:di_ellipse.">)")
  let b:di_vert    = a:di_vert
  let b:di_horiz   = a:di_horiz
  let b:di_plus    = a:di_plus
  let b:di_upleft  = a:di_upleft
  let b:di_upright = a:di_upright
  let b:di_cross   = a:di_cross
  let b:di_ellipse = a:di_ellipse
"  call Dret("SetDrawIt")
endfun

" =====================================================================
" s:DrawLeft: {{{2
fun! s:DrawLeft()
"  call Dfunc("s:DrawLeft()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 2

  if curcol > 0
    let curchar= strpart(curline,curcol-1,1)

    " replace
   if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
   else
     exe "norm! r".b:di_horiz
   endif

   " move and replace
   if curcol >= 2
    call s:MoveLeft()
    let curchar= strpart(curline,curcol-2,1)
    if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_horiz
    endif
   endif
  endif
"  call Dret("s:DrawLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawRight: {{{2
fun! s:DrawRight()
"  call Dfunc("s:DrawRight()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 1

  " replace
  if curcol == virtcol("$")
   exe "norm! a".b:di_horiz."\<Esc>"
  else
    let curchar= strpart(curline,curcol-1,1)
    if curchar == b:di_vert || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_horiz
    endif
  endif

  " move and replace
  call s:MoveRight()
  if curcol == virtcol("$")
   exe "norm! i".b:di_horiz."\<Esc>"
  else
   let curchar= strpart(curline,curcol,1)
   if curchar == b:di_vert || curchar == b:di_plus
    exe "norm! r".b:di_plus
   else
    exe "norm! r".b:di_horiz
   endif
  endif
"  call Dret("s:DrawRight")
endfun

" ---------------------------------------------------------------------
" s:DrawUp: {{{2
fun! s:DrawUp()
"  call Dfunc("s:DrawUp()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 3

  " replace
  if curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  else
   let curchar= strpart(curline,curcol-1,1)
   if curchar == b:di_horiz || curchar == b:di_plus
    exe "norm! r".b:di_plus
   else
    exe "norm! r".b:di_vert
   endif
  endif

  " move and replace/insert
  call s:MoveUp()
  let curline= getline(".")
  let curchar= strpart(curline,curcol-1,1)

  if     curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  elseif curchar == b:di_horiz || curchar == b:di_plus
   exe "norm! r".b:di_plus
  else
   exe "norm! r".b:di_vert
   endif
  endif
"  call Dret("s:DrawUp")
endfun

" ---------------------------------------------------------------------
" s:DrawDown: {{{2
fun! s:DrawDown()
"  call Dfunc("s:DrawDown()")
  let curline   = getline(".")
  let curcol    = virtcol(".")
  let b:lastdir = 4

  " replace
  if curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  else
    let curchar= strpart(curline,curcol-1,1)
    if curchar == b:di_horiz || curchar == b:di_plus
     exe "norm! r".b:di_plus
    else
     exe "norm! r".b:di_vert
    endif
  endif

  " move and replace/insert
  call s:MoveDown()
  let curline= getline(".")
  let curchar= strpart(curline,curcol-1,1)
  if     curcol == 1 && virtcol("$") == 1
   exe "norm! i".b:di_vert."\<Esc>"
  elseif curchar == b:di_horiz || curchar == b:di_plus
   exe "norm! r".b:di_plus
  else
   exe "norm! r".b:di_vert
  endif
"  call Dret("s:DrawDown")
endfun

" ---------------------------------------------------------------------
" s:DrawErase: toggle [DrawIt on] and [DrawIt erase] modes {{{2
fun! s:DrawErase()
"  call Dfunc("s:DrawErase() b:di_erase=".b:di_erase)
  if b:di_erase == 0
   let b:di_erase= 1
   echo "[DrawIt erase]"
   let b:di_vert_save    = b:di_vert
   let b:di_horiz_save   = b:di_horiz
   let b:di_plus_save    = b:di_plus
   let b:di_upright_save = b:di_upright
   let b:di_upleft_save  = b:di_upleft
   let b:di_cross_save   = b:di_cross
   let b:di_ellipse_save = b:di_ellipse
   call SetDrawIt(' ',' ',' ',' ',' ',' ',' ')
  else
   let b:di_erase= 0
   echo "[DrawIt]"
   call SetDrawIt(b:di_vert_save,b:di_horiz_save,b:di_plus_save,b:di_upleft_save,b:di_upright_save,b:di_cross_save,b:di_ellipse_save)
  endif
"  call Dret("s:DrawErase")
endfun

" ---------------------------------------------------------------------
" s:DrawSpace: clear character and move right {{{2
fun! s:DrawSpace(chr,dir)
"  call Dfunc("s:DrawSpace(chr<".a:chr."> dir<".a:dir.">)")
  let curcol= virtcol(".")

  " replace current location with arrowhead/space
  if curcol == virtcol("$")-1
   exe "norm! r".a:chr
  else
   exe "norm! r".a:chr
  endif

  if a:dir == 0
   let dir= b:lastdir
  else
   let dir= a:dir
  endif

  " perform specified move
  if dir == 1
   call s:MoveRight()
  elseif dir == 2
   call s:MoveLeft()
  elseif dir == 3
   call s:MoveUp()
  else
   call s:MoveDown()
  endif
"  call Dret("s:DrawSpace")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantDownLeft: / {{{2
fun! s:DrawSlantDownLeft()
"  call Dfunc("s:DrawSlantDownLeft()")
  call s:ReplaceDownLeft()		" replace
  call s:MoveDown()				" move
  call s:MoveLeft()				" move
  call s:ReplaceDownLeft()		" replace
"  call Dret("s:DrawSlantDownLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantDownRight: \ {{{2
fun! s:DrawSlantDownRight()
"  call Dfunc("s:DrawSlantDownRight()")
  call s:ReplaceDownRight()	" replace
  call s:MoveDown()			" move
  call s:MoveRight()		" move
  call s:ReplaceDownRight()	" replace
"  call Dret("s:DrawSlantDownRight")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantUpLeft: \ {{{2
fun! s:DrawSlantUpLeft()
"  call Dfunc("s:DrawSlantUpLeft()")
  call s:ReplaceDownRight()	" replace
  call s:MoveUp()			" move
  call s:MoveLeft()			" move
  call s:ReplaceDownRight()	" replace
"  call Dret("s:DrawSlantUpLeft")
endfun

" ---------------------------------------------------------------------
" s:DrawSlantUpRight: / {{{2
fun! s:DrawSlantUpRight()
"  call Dfunc("s:DrawSlantUpRight()")
  call s:ReplaceDownLeft()	" replace
  call s:MoveUp()			" move
  call s:MoveRight()		" replace
  call s:ReplaceDownLeft()	" replace
"  call Dret("s:DrawSlantUpRight")
endfun

" ---------------------------------------------------------------------
" s:MoveLeft: {{{2
fun! s:MoveLeft()
"  call Dfunc("s:MoveLeft()")
  norm! h
  let b:lastdir= 2
"  call Dret("s:MoveLeft : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveRight: {{{2
fun! s:MoveRight()
"  call Dfunc("s:MoveRight()")
  if virtcol(".") >= virtcol("$") - 1
   exe "norm! A \<Esc>"
  else
   norm! l
  endif
  let b:lastdir= 1
"  call Dret("s:MoveRight : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveUp: {{{2
fun! s:MoveUp()
"  call Dfunc("s:MoveUp()")
  if line(".") == 1
   let curcol= virtcol(".") - 1
   if curcol == 0 && virtcol("$") == 1
     exe "norm! i \<Esc>"
   elseif curcol == 0
     exe "norm! YP:s/./ /ge\<CR>0r "
   else
     exe "norm! YP:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= virtcol(".")
   norm! k
   while virtcol("$") <= curcol
     exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 3
"  call Dret("s:MoveUp : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:MoveDown: {{{2
fun! s:MoveDown()
"  call Dfunc("s:MoveDown()")
  if line(".") == line("$")
   let curcol= virtcol(".") - 1
   if curcol == 0 && virtcol("$") == 1
    exe "norm! i \<Esc>"
   elseif curcol == 0
    exe "norm! Yp:s/./ /ge\<CR>0r "
   else
    exe "norm! Yp:s/./ /ge\<CR>0".curcol."lr "
   endif
  else
   let curcol= virtcol(".")
   norm! j
   while virtcol("$") <= curcol
    exe "norm! A \<Esc>"
   endwhile
  endif
  let b:lastdir= 4
"  call Dret("s:MoveDown : b:lastdir=".b:lastdir)
endfun

" ---------------------------------------------------------------------
" s:ReplaceDownLeft: / X  (upright) {{{2
fun! s:ReplaceDownLeft()
"  call Dfunc("s:ReplaceDownLeft()")
  let curcol = virtcol(".")
  if curcol != virtcol("$")
   let curchar= strpart(getline("."),curcol-1,1)
   if curchar == "\\" || curchar == "X"
    exe "norm! r".b:di_cross
   else
    exe "norm! r".b:di_upright
   endif
  else
   exe "norm! i".b:di_upright."\<Esc>"
  endif
"  call Dret("s:ReplaceDownLeft")
endfun

" ---------------------------------------------------------------------
" s:ReplaceDownRight: \ X  (upleft) {{{2
fun! s:ReplaceDownRight()
"  call Dfunc("s:ReplaceDownRight()")
  let curcol = virtcol(".")
  if curcol != virtcol("$")
   let curchar= strpart(getline("."),curcol-1,1)
   if curchar == "/" || curchar == "X"
    exe "norm! r".b:di_cross
   else
    exe "norm! r".b:di_upleft
   endif
  else
   exe "norm! i".b:di_upleft."\<Esc>"
  endif
"  call Dret("s:ReplaceDownRight")
endfun

" ---------------------------------------------------------------------
" s:DrawFatRArrow: ----|> {{{2
fun! s:DrawFatRArrow()
"  call Dfunc("s:DrawFatRArrow()")
  call s:MoveRight()
  norm! r|
  call s:MoveRight()
  norm! r>
"  call Dret("s:DrawFatRArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawFatLArrow: <|---- {{{2
fun! s:DrawFatLArrow()
"  call Dfunc("s:DrawFatLArrow()")
  call s:MoveLeft()
  norm! r|
  call s:MoveLeft()
  norm! r<
"  call Dret("s:DrawFatLArrow")
endfun

" ---------------------------------------------------------------------
"                 .
" s:DrawFatUArrow: /_\ {{{2
"                 |
fun! s:DrawFatUArrow()
"  call Dfunc("s:DrawFatUArrow()")
  call s:MoveUp()
  norm! r_
  call s:MoveRight()
  norm! r\
  call s:MoveLeft()
  call s:MoveLeft()
  norm! r/
  call s:MoveRight()
  call s:MoveUp()
  norm! r.
"  call Dret("s:DrawFatUArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawFatDArrow: _|_ {{{2
"                  \ /
"                   '
fun! s:DrawFatDArrow()
"  call Dfunc("s:DrawFatDArrow()")
  call s:MoveRight()
  norm! r_
  call s:MoveLeft()
  call s:MoveLeft()
  norm! r_
  call s:MoveDown()
  norm! r\
  call s:MoveRight()
  call s:MoveRight()
  norm! r/
  call s:MoveDown()
  call s:MoveLeft()
  norm! r'
"  call Dret("s:DrawFatDArrow")
endfun

" ---------------------------------------------------------------------
" s:DrawEllipse: Bresenham-like ellipse drawing algorithm {{{2
"      2   2      can
"     x   y       be             2 2   2 2   2 2
"     - + - = 1   rewritten     b x + a y = a b
"     a   b       as
"
"     Take step which has minimum error
"     (x,y-1)  (x+1,y)  (x+1,y-1)
"
"             2 2   2 2   2 2
"     Ei = | b x + a y - a b |
"
"     Algorithm only draws arc from (0,b) to (a,0) and uses
"     DrawFour() to reflect points to other three quadrants
fun! s:DrawEllipse(x0,y0,x1,y1)
"  call Dfunc("s:DrawEllipse(x0=".a:x0." y0=".a:y0." x1=".a:x1." y1=".a:y1.")")
  let x0   = a:x0
  let y0   = a:y0
  let x1   = a:x1
  let y1   = a:y1
  let xoff = (x0+x1)/2
  let yoff = (y0+y1)/2
  let a    = s:Abs(x1-x0)/2
  let b    = s:Abs(y1-y0)/2
  let a2   = a*a
  let b2   = b*b
  let twoa2= a2 + a2
  let twob2= b2 + b2

  let xi= 0
  let yi= b
  let ei= 0
  call s:DrawFour(xi,yi,xoff,yoff,a,b)
  while xi <= a && yi >= 0

     let dy= a2 - twoa2*yi
     let ca= ei + twob2*xi + b2
     let cb= ca + dy
     let cc= ei + dy

     let aca= s:Abs(ca)
     let acb= s:Abs(cb)
     let acc= s:Abs(cc)

     " pick case: (xi+1,yi) (xi,yi-1) (xi+1,yi-1)
     if aca <= acb && aca <= acc
        let xi= xi + 1
        let ei= ca
     elseif acb <= aca && acb <= acc
        let ei= cb
        let xi= xi + 1
        let yi= yi - 1
     else
        let ei= cc
        let yi= yi - 1
     endif
     if xi > a:x1
        break
     endif
     call s:DrawFour(xi,yi,xoff,yoff,a,b)
  endw
"  call Dret("s:DrawEllipse")
endf

" ---------------------------------------------------------------------
" s:DrawFour: reflect a point to four quadrants {{{2
fun! s:DrawFour(x,y,xoff,yoff,a,b)
"  call Dfunc("s:DrawFour(xy[".a:x.",".a:y."] off[".a:xoff.",".a:yoff."] a=".a:a." b=".a:b.")")
  let x  = a:xoff + a:x
  let y  = a:yoff + a:y
  let lx = a:xoff - a:x
  let by = a:yoff - a:y
  call s:SetCharAt(b:di_ellipse,  x, y)
  call s:SetCharAt(b:di_ellipse, lx, y)
  call s:SetCharAt(b:di_ellipse, lx,by)
  call s:SetCharAt(b:di_ellipse,  x,by)
"  call Dret("s:DrawFour")
endf

" ---------------------------------------------------------------------
" s:SavePosn: saves position of cursor on screen so NetWrite can restore it {{{2
fun! s:SavePosn()
"  call Dfunc("s:SavePosn() saveposn_count=".s:saveposn_count.' ['.line('.').','.virtcol('.').']')
  let s:saveposn_count= s:saveposn_count + 1

  " Save current line and column
  let b:drawit_line_{s:saveposn_count} = line(".")
  let b:drawit_col_{s:saveposn_count}  = virtcol(".") - 1

  " Save top-of-screen line
  norm! H
  let b:drawit_hline_{s:saveposn_count}= line(".")

  " restore position
  exe "norm! ".b:drawit_hline_{s:saveposn_count}."G0z\<CR>"
  if b:drawit_col_{s:saveposn_count} == 0
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0"
  else
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0".b:drawit_col_{s:saveposn_count}."l"
  endif
"  call Dret("s:SavePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" s:RestorePosn: {{{2
fun! s:RestorePosn()
"  call Dfunc("s:RestorePosn() saveposn_count=".s:saveposn_count)
  if s:saveposn_count <= 0
"  	call Dret("s:RestorePosn : s:saveposn_count<=0")
  	return
  endif
  " restore top-of-screen line
  exe "norm! ".b:drawit_hline_{s:saveposn_count}."G0z\<CR>"

  " restore position
  if b:drawit_col_{s:saveposn_count} == 0
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0"
  else
   exe "norm! ".b:drawit_line_{s:saveposn_count}."G0".b:drawit_col_{s:saveposn_count}."l"
  endif
  if s:saveposn_count > 0
	unlet b:drawit_hline_{s:saveposn_count}
	unlet b:drawit_line_{s:saveposn_count}
	unlet b:drawit_col_{s:saveposn_count}
   let s:saveposn_count= s:saveposn_count - 1
  endif
"  call Dret("s:RestorePosn : saveposn_count=".s:saveposn_count)
endfun

" ------------------------------------------------------------------------
" s:Flood: this function begins a flood of a region {{{2
"        based on b:di... characters as boundaries
"        and starting at the current cursor location.
fun! s:Flood()
"  call Dfunc("s:Flood()")

  let s:bndry  = b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross.b:di_ellipse
  let row      = line(".")
  let col      = virtcol(".")
  let athold   = @0
  let s:DIrows = line("$")
  call s:SavePosn()

  " get fill character from user
  " Put entire fillchar string into the s:bndry (boundary characters),
  " although only use the first such character for filling
  call inputsave()
  let s:fillchar= input("Enter fill character: ")
  call inputrestore()
  let s:bndry= "[".escape(s:bndry.s:fillchar,'\-]^')."]"
  if strlen(s:fillchar) > 1
   let s:fillchar= strpart(s:fillchar,0,1)
  endif

  " flood the region
  call s:DI_Flood(row,col)

  " restore
  call s:RestorePosn()
  let @0= athold
  unlet s:DIrows s:bndry s:fillchar

"  call Dret("s:Flood")
endfun

" ------------------------------------------------------------------------
" s:DI_Flood: fill up to the boundaries all characters to the left and right. {{{2
"           Then, based on the left/right column extents reached, check
"           adjacent rows to see if any characters there need filling.
fun! s:DI_Flood(frow,fcol)
"  call Dfunc("s:DI_Flood(frow=".a:frow." fcol=".a:fcol.")")
  if a:frow <= 0 || a:fcol <= 0 || s:SetPosn(a:frow,a:fcol) || s:IsBoundary(a:frow,a:fcol)
"   call Dret("s:DI_Flood")
   return
  endif

  " fill current line
  let colL= s:DI_FillLeft(a:frow,a:fcol)
  let colR= s:DI_FillRight(a:frow,a:fcol+1)

  " do a filladjacent on the next line up
  if a:frow > 1
   call s:DI_FillAdjacent(a:frow-1,colL,colR)
  endif

  " do a filladjacent on the next line down
  if a:frow < s:DIrows
   call s:DI_FillAdjacent(a:frow+1,colL,colR)
  endif

"  call Dret("s:DI_Flood")
endfun

" ------------------------------------------------------------------------
"  s:DI_FillLeft: Starting at (frow,fcol), non-boundary locations are {{{2
"               filled with the fillchar.  The leftmost extent reached
"               is returned.
fun! s:DI_FillLeft(frow,fcol)
"  call Dfunc("s:DI_FillLeft(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("s:DI_FillLeft ".a:fcol)
   return a:fcol
  endif

  let Lcol= a:fcol
  while Lcol >= 1
   if !s:IsBoundary(a:frow,Lcol)
    exe  "silent! norm! r".s:fillchar."h"
   else
    break
   endif
   let Lcol= Lcol - 1
  endwhile

 let Lcol= (Lcol < 1)? 1 : Lcol + 1

" call Dret("s:DI_FillLeft ".Lcol)
 return Lcol
endfun

" ---------------------------------------------------------------------
"  s:DI_FillRight: Starting at (frow,fcol), non-boundary locations are {{{2
"                filled with the fillchar.  The rightmost extent reached
"                is returned.
fun! s:DI_FillRight(frow,fcol)
"  call Dfunc("s:DI_FillRight(frow=".a:frow." fcol=".a:fcol.")")
  if s:SetPosn(a:frow,a:fcol)
"   call Dret("s:DI_FillRight ".a:fcol)
   return a:fcol
  endif

  let Rcol   = a:fcol
  while Rcol <= virtcol("$")
   if !s:IsBoundary(a:frow,Rcol)
    exe "silent! norm! r".s:fillchar."l"
   else
    break
   endif
   let Rcol= Rcol + 1
  endwhile

  let DIcols = virtcol("$")
  let Rcol   = (Rcol > DIcols)? DIcols : Rcol - 1

"  call Dret("s:DI_FillRight ".Rcol)
  return Rcol
endfun

" ---------------------------------------------------------------------
"  s:DI_FillAdjacent: {{{2
"     DI_Flood does FillLeft and FillRight, so the run from left to right
"    (fcolL to fcolR) is known to have been filled.  FillAdjacent is called
"    from (fcolL to fcolR) on the lines one row up and down; if any character
"    on the run is not a boundary character, then a flood is needed on that
"    location.
fun! s:DI_FillAdjacent(frow,fcolL,fcolR)
"  call Dfunc("s:DI_FillAdjacent(frow=".a:frow." fcolL=".a:fcolL." fcolR=".a:fcolR.")")

  let icol  = a:fcolL
  while icol <= a:fcolR
	if !s:IsBoundary(a:frow,icol)
	 call s:DI_Flood(a:frow,icol)
	endif
   let icol= icol + 1
  endwhile

"  call Dret("s:DI_FillAdjacent")
endfun

" ---------------------------------------------------------------------
" s:SetPosn: set cursor to given position on screen {{{2
"    srow,scol: -s-creen    row and column
"   Returns  1 : failed sanity check
"            0 : otherwise
fun! s:SetPosn(row,col)
"  call Dfunc("s:SetPosn(row=".a:row." col=".a:col.")")
  " sanity checks
  if a:row < 1
"   call Dret("s:SetPosn 1")
   return 1
  endif
  if a:col < 1
"   call Dret("s:SetPosn 1")
   return 1
  endif

  exe "norm! ".a:row."G".a:col."\<Bar>"

"  call Dret("s:SetPosn 0")
  return 0
endfun

" ---------------------------------------------------------------------
" s:IsBoundary: returns 0 if not on boundary, 1 if on boundary {{{2
"             The "boundary" also includes the fill character.
fun! s:IsBoundary(row,col)
"  call Dfunc("s:IsBoundary(row=".a:row." col=".a:col.")")

  let orow= line(".")
  let ocol= virtcol(".")
  exe "norm! ".a:row."G".a:col."\<Bar>"
  norm! vy
  let ret= @0 =~ s:bndry
  if a:row != orow || a:col != ocol
   exe "norm! ".orow."G".ocol."\<Bar>"
  endif

"  call Dret("s:IsBoundary ".ret." : @0<".@0.">")
  return ret
endfun

" ---------------------------------------------------------------------
" s:PutBlock: puts a register's contents into the text at the current {{{2
"           cursor location
"              replace= 0: Blanks are transparent
"                     = 1: Blanks copy over
"                     = 2: Erase all drawing characters
"
fun! s:PutBlock(block,replace)
"  call Dfunc("s:PutBlock(block<".a:block."> replace=".a:replace.")")
  call s:SavePosn()
  exe "let block  = @".a:block
  let blocklen    = strlen(block)
  let drawit_line = line('.')
  let drawchars   = '['.escape(b:di_vert.b:di_horiz.b:di_plus.b:di_upright.b:di_upleft.b:di_cross,'\-').']'

  " insure that putting a block will do so in a region containing spaces out to textwidth
  exe "let blockrows= strlen(substitute(@".a:block.",'[^[:cntrl:]]','','g'))"
  exe 'let blockcols= strlen(substitute(@'.a:block.",'^\\(.\\{-}\\)\\n\\_.*$','\\1',''))"
  let curline= line('.')
  let curcol = virtcol('.')
"  call Decho("blockrows=".blockrows." blockcols=".blockcols." curline=".curline." curcol=".curcol)
  call s:AutoCanvas(curline-1,curline + blockrows+1,curcol + blockcols)

  let iblock      = 0
  while iblock < blocklen
  	let chr= strpart(block,iblock,1)

	if char2nr(chr) == 10
	 " handle newline
	 let drawit_line= drawit_line + 1
    if b:drawit_col_{s:saveposn_count} == 0
     exe "norm! ".drawit_line."G0"
    else
     exe "norm! ".drawit_line."G0".b:drawit_col_{s:saveposn_count}."l"
    endif

	elseif a:replace == 2
	 " replace all drawing characters with blanks
	 if match(chr,drawchars) != -1
	  norm! r l
	 else
	  norm! l
	 endif

	elseif chr == ' ' && a:replace == 0
	 " allow blanks to be transparent
	 norm! l

	else
	 " usual replace character
	 exe "norm! r".chr."l"
	endif
  	let iblock = iblock + 1
  endwhile
  call s:RestorePosn()

"  call Dret("s:PutBlock")
endfun

" ---------------------------------------------------------------------
" s:AutoCanvas: automatic "Canvas" routine {{{2
fun! s:AutoCanvas(linestart,linestop,cols)
"  call Dfunc("s:AutoCanvas(linestart=".a:linestart." linestop=".a:linestop." cols=".a:cols.")  line($)=".line("$"))

  " insure there's enough blank lines at end-of-file
  if line("$") < a:linestop
"   call Decho("append ".(a:linestop - line("$"))." empty lines")
   call s:SavePosn()
   exe "norm! G".(a:linestop - line("$"))."o\<esc>"
   call s:RestorePosn()
  endif

  " insure that any tabs contained within the selected region are converted to blanks
  let etkeep= &et
  set et
"  call Decho("exe ".a:linestart.",".a:linestop."retab")
  exe a:linestart.",".a:linestop."retab"
  let &et= etkeep

  " insure that there's whitespace to textwidth/screenwidth/a:cols
  if a:cols <= 0
   let tw= &tw
   if tw <= 0
    let tw= &columns
   endif
  else
   let tw= a:cols
  endif
"  Decho("tw=".tw)
  if search('^$\|.\%<'.(tw+1).'v$',"cn",(a:linestop+1)) > 0
"   call Decho("append trailing whitespace")
   call s:Spacer(a:linestart,a:linestop,tw)
  endif

"  call Dret("s:AutoCanvas : tw=".tw)
endfun

" =====================================================================
"  DrawIt Functions: (by Sylvain Viart) {{{1
" =====================================================================

" ---------------------------------------------------------------------
" s:Canvas: {{{2
fun! s:Canvas()
"  call Dfunc("s:Canvas()")

  let lines  = input("how many lines under the cursor? ")
  let curline= line('.')
  if curline < line('$')
   exe "norm! ".lines."o\<esc>"
  endif
  call s:Spacer(curline+1,curline+lines,0)
  let b:drawit_canvas_used= 1

"  call Dret("s:Canvas")
endf

" ---------------------------------------------------------------------
" s:Spacer: fill end of line with space {{{2
"         if a:cols >0: to the virtual column specified by a:cols
"                  <=0: to textwidth (if nonzero), otherwise
"                       to display width (&columns)
fun! s:Spacer(debut, fin, cols) range
"  call Dfunc("s:Spacer(debut=".a:debut." fin=".a:fin." cols=".a:cols.")")
  call s:SavePosn()

  if a:cols <= 0
   let width = &textwidth
   if width <= 0
    let width= &columns
   endif
  else
   let width= a:cols
  endif

  let l= a:debut
  while l <= a:fin
   call setline(l,printf('%-'.width.'s',getline(l)))
   let l = l + 1
  endwhile

  call s:RestorePosn()

"  call Dret("s:Spacer")
endf

" ---------------------------------------------------------------------
" s:CallBox: call the specified function using the current visual selection box {{{2
fun! s:CallBox(func_name)
"  call Dfunc("s:CallBox(func_name<".a:func_name.">)")

  let xdep = b:xmouse_start
  let ydep = b:ymouse_start
  let col0   = virtcol("'<")
  let row0   = line("'<")
  let col1   = virtcol("'>")
  let row1   = line("'>")
"  call Decho("TL corner[".row0.",".col0."] original")
"  call Decho("BR corner[".row1.",".col1."] original")
"  call Decho("xydep     [".ydep.",".xdep."]")

  if col1 == xdep && row1 == ydep
     let col1 = col0
     let row1 = row0
     let col0 = xdep
     let row0 = ydep
  endif
"  call Decho("TL corner[".row0.",".col0."]")
"  call Decho("BR corner[".row1.",".col1."]")

  " insure that the selected region has blanks to that specified by col1
  call s:AutoCanvas((row0 < row1)? row0 : row1,(row1 > row0)? row1 : row0,(col1 > col0)? col1 : col0)

"  call Decho("exe call s:".a:func_name."(".col0.','.row0.','.col1.','.row1.")")
  exe "call s:".a:func_name."(".col0.','.row0.','.col1.','.row1.")"
  let b:xmouse_start= 0
  let b:ymouse_start= 0

"  call Dret("s:CallBox")
endf

" ---------------------------------------------------------------------
" s:DrawBox: {{{2
fun! s:DrawBox(x0, y0, x1, y1)
"  call Dfunc("s:DrawBox(xy0[".a:x0.",".a:y0." xy1[".a:x1.",".a:y1."])")
   " loop each line
   let l = a:y0
   while l <= a:y1
      let c = a:x0
      while c <= a:x1
         if l == a:y0 || l == a:y1
            let remp = '-'
            if c == a:x0 || c == a:x1
               let remp = '+'
            endif
         else
            let remp = '|'
            if c != a:x0 && c != a:x1
               let remp = '.'
            endif
         endif

         if remp != '.'
            call s:SetCharAt(remp, c, l)
         endif
         let c  = c + 1
      endw
      let l = l + 1
   endw

"  call Dret("s:DrawBox")
endf

" ---------------------------------------------------------------------
" s:SetCharAt: set the character at the specified position (must exist) {{{2
fun! s:SetCharAt(char, x, y)
"  call Dfunc("s:SetCharAt(char<".a:char."> xy[".a:x.",".a:y."])")

  let content = getline(a:y)
  let long    = strlen(content)
  let deb     = strpart(content, 0, a:x - 1)
  let fin     = strpart(content, a:x, long)
  call setline(a:y, deb.a:char.fin)

"  call Dret("s:SetCharAt")
endf

" ---------------------------------------------------------------------
" s:DrawLine: Bresenham line-drawing algorithm {{{2
" taken from :
" http://www.graphics.lcs.mit.edu/~mcmillan/comp136/Lecture6/Lines.html
fun! s:DrawLine(x0, y0, x1, y1, horiz)
"  call Dfunc("s:DrawLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."] horiz=".a:horiz.")")

  if ( a:x0 < a:x1 && a:y0 > a:y1 ) || ( a:x0 > a:x1 && a:y0 > a:y1 )
    " swap direction
    let x0   = a:x1
    let y0   = a:y1
    let x1   = a:x0
    let y1   = a:y0
  else
    let x0 = a:x0
    let y0 = a:y0
    let x1 = a:x1
    let y1 = a:y1
  endif
  let dy = y1 - y0
  let dx = x1 - x0

  if dy < 0
     let dy    = -dy
     let stepy = -1
  else
     let stepy = 1
  endif

  if dx < 0
     let dx    = -dx
     let stepx = -1
  else
     let stepx = 1
  endif

  let dy = 2*dy
  let dx = 2*dx

  if dx > dy
     " move under x
     let char = a:horiz
     call s:SetCharAt(char, x0, y0)
     let fraction = dy - (dx / 2)  " same as 2*dy - dx
     while x0 != x1
        let char = a:horiz
        if fraction >= 0
           if stepx > 0
              let char = '\'
           else
              let char = '/'
           endif
           let y0 = y0 + stepy
           let fraction = fraction - dx    " same as fraction -= 2*dx
        endif
        let x0 = x0 + stepx
        let fraction = fraction + dy	" same as fraction = fraction - 2*dy
        call s:SetCharAt(char, x0, y0)
     endw
  else
     " move under y
     let char = '|'
     call s:SetCharAt(char, x0, y0)
     let fraction = dx - (dy / 2)
     while y0 != y1
        let char = '|'
        if fraction >= 0
           if stepy > 0 || stepx < 0
              let char = '\'
           else
              let char = '/'
           endif
           let x0 = x0 + stepx
           let fraction = fraction - dy
        endif
        let y0 = y0 + stepy
        let fraction = fraction + dx
        call s:SetCharAt(char, x0, y0)
     endw
  endif

"  call Dret("s:DrawLine")
endf

" ---------------------------------------------------------------------
" s:Arrow: {{{2
fun! s:Arrow(x0, y0, x1, y1)
"  call Dfunc("s:Arrow(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

  call s:DrawLine(a:x0, a:y0, a:x1, a:y1,'-')
  let dy = a:y1 - a:y0
  let dx = a:x1 - a:x0
  if s:Abs(dx) > <SID>Abs(dy)
     " move x
     if dx > 0
        call s:SetCharAt('>', a:x1, a:y1)
     else
        call s:SetCharAt('<', a:x1, a:y1)
     endif
  else
     " move y
     if dy > 0
        call s:SetCharAt('v', a:x1, a:y1)
     else
        call s:SetCharAt('^', a:x1, a:y1)
     endif
  endif

"  call Dret("s:Arrow")
endf

" ---------------------------------------------------------------------
" s:Abs: return absolute value {{{2
fun! s:Abs(val)
  if a:val < 0
   return - a:val
  else
   return a:val
  endif
endf

" ---------------------------------------------------------------------
" s:DrawPlainLine: {{{2
fun! s:DrawPlainLine(x0,y0,x1,y1)
"  call Dfunc("s:DrawPlainLine(xy0[".a:x0.",".a:y0."] xy1[".a:x1.",".a:y1."])")

"   call Decho("exe call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")')
   exe "call s:DrawLine(".a:x0.','.a:y0.','.a:x1.','.a:y1.',"_")'

"  call Dret("s:DrawPlainLine")
endf

" =====================================================================
"  Mouse Functions: {{{1
" =====================================================================

" ---------------------------------------------------------------------
" s:LeftStart: Read visual drag mapping {{{2
" The visual start point is saved in b:xmouse_start and b:ymouse_start
fun! s:LeftStart()
"  call Dfunc("s:LeftStart()")
  let b:xmouse_start = virtcol('.')
  let b:ymouse_start = line('.')
  vnoremap <silent> <leftrelease> <leftrelease>:<c-u>call <SID>LeftRelease()<cr>gv
"  call Dret("s:LeftStart : [".b:ymouse_start.",".b:xmouse_start."]")
endf!

" ---------------------------------------------------------------------
" s:LeftRelease: {{{2
fun! s:LeftRelease()
"  call Dfunc("s:LeftRelease()")
  vunmap <leftrelease>
"  call Dret("s:LeftRelease : [".line('.').','.virtcol('.').']')
endf

" ---------------------------------------------------------------------
" s:SLeftStart: begin drawing with a brush {{{2
fun! s:SLeftStart()
  if !exists("b:drawit_brush")
   let b:drawit_brush= "a"
  endif
"  call Dfunc("s:SLeftStart() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  noremap <silent> <s-leftdrag>    <leftmouse>:<c-u>call <SID>SLeftDrag()<cr>
  noremap <silent> <s-leftrelease> <leftmouse>:<c-u>call <SID>SLeftRelease()<cr>
"  call Dret("s:SLeftStart")
endfun

" ---------------------------------------------------------------------
" s:SLeftDrag: {{{2
fun! s:SLeftDrag()
"  call Dfunc("s:SLeftDrag() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  call s:SavePosn()
  call s:PutBlock(b:drawit_brush,0)
  call s:RestorePosn()
"  call Dret("s:SLeftDrag")
endfun

" ---------------------------------------------------------------------
" s:SLeftRelease: {{{2
fun! s:SLeftRelease()
"  call Dfunc("s:SLeftRelease() brush=".b:drawit_brush.' ['.line('.').','.virtcol('.').']')
  call s:SLeftDrag()
  nunmap <s-leftdrag>
  nunmap <s-leftrelease>
"  call Dret("s:SLeftRelease")
endfun

" ---------------------------------------------------------------------
" s:CLeftStart: begin moving a block of text {{{2
fun! s:CLeftStart()
  if !exists("b:drawit_brush")
   let b:drawit_brush= "a"
  endif
"  call Dfunc("s:CLeftStart() brush=".b:drawit_brush)
  if !line("'<") || !line("'>")
   redraw!
   echohl Error
   echo "must visual-block select a region first"
"   call Dret("s:CLeftStart : must visual-block select a region first")
   return
  endif
  '<,'>call DrawIt#SetBrush(b:drawit_brush)
  let s:cleft_width= virtcol("'>") - virtcol("'<")
  if s:cleft_width < 0
   let s:cleft_width= -s:cleft_width
  endif
  let s:cleft_height= line("'>") - line("'<")
  if s:cleft_height < 0
   let s:cleft_height= -s:cleft_height
  endif
  if exists("s:cleft_oldblock")
   unlet s:cleft_oldblock
  endif
"  call Decho("blocksize: ".s:cleft_height."x".s:cleft_width)
  noremap <silent> <c-leftdrag>    :<c-u>call <SID>CLeftDrag()<cr>
  noremap <silent> <c-leftrelease> <leftmouse>:<c-u>call <SID>CLeftRelease()<cr>
"  call Dret("s:CLeftStart")
endfun

" ---------------------------------------------------------------------
" s:CLeftDrag: {{{2
fun! s:CLeftDrag()
"  call Dfunc("s:CLeftDrag() cleft_width=".s:cleft_width." cleft_height=".s:cleft_height)
  exe 'let keepbrush= @'.b:drawit_brush
"  call Decho("keepbrush<".keepbrush.">")

  " restore prior contents of block zone
  if exists("s:cleft_oldblock")
"   call Decho("draw prior contents: [".line(".").",".virtcol(".")."] line($)=".line("$"))
"   call Decho("draw prior contents<".s:cleft_oldblock.">")
   exe 'let @'.b:drawit_brush.'=s:cleft_oldblock'
   call s:PutBlock(b:drawit_brush,1)
  endif

  " move cursor to <leftmouse> position
  exe "norm! \<leftmouse>"

  " save new block zone contents
"  call Decho("save contents: [".line(".").",".virtcol(".")."] - [".(line(".")+s:cleft_height).",".(virtcol(".")+s:cleft_width)."]")
  let curline= line(".")
  call s:AutoCanvas(curline,curline + s:cleft_height,virtcol(".")+s:cleft_width)
  if s:cleft_width > 0 && s:cleft_height > 0
   exe "silent! norm! \<c-v>".s:cleft_width."l".s:cleft_height.'j"'.b:drawit_brush.'y'
  elseif s:cleft_width > 0
   exe "silent! norm! \<c-v>".s:cleft_width.'l"'.b:drawit_brush.'y'
  else
   exe "silent! norm! \<c-v>".s:cleft_height.'j"'.b:drawit_brush.'y'
  endif
  exe "let s:cleft_oldblock= @".b:drawit_brush
"  call Decho("s:cleft_oldblock=@".b:drawit_brush)
"  call Decho("cleft_height=".s:cleft_height." cleft_width=".s:cleft_width)
"  call Decho("save contents<".s:cleft_oldblock.">")

  " draw the brush
"  call Decho("draw brush")
"  call Decho("draw brush ".b:drawit_brush.": [".line(".").",".virtcol(".")."] line($)=".line("$"))
  exe 'let @'.b:drawit_brush.'=keepbrush'
  call s:PutBlock(b:drawit_brush,1)

"  call Dret("s:CLeftDrag")
endfun

" ---------------------------------------------------------------------
" s:CLeftRelease: {{{2
fun! s:CLeftRelease()
"  call Dfunc("s:CLeftRelease()")
  call s:CLeftDrag()
  nunmap <c-leftdrag>
  nunmap <c-leftrelease>
  unlet s:cleft_oldblock s:cleft_height s:cleft_width
"  call Dret("s:CLeftRelease")
endfun

" ---------------------------------------------------------------------
" DrawIt#SetBrush: {{{2
fun! DrawIt#SetBrush(brush) range
"  call Dfunc("DrawIt#SetBrush(brush<".a:brush.">)")
  let b:drawit_brush= a:brush
"  call Decho("visualmode<".visualmode()."> range[".a:firstline.",".a:lastline."] visrange[".line("'<").",".line("'>")."]")
  if visualmode() == "\<c-v>" && ((a:firstline == line("'>") && a:lastline == line("'<")) || (a:firstline == line("'<") && a:lastline == line("'>")))
   " last visual mode was visual block mode, and
   " either [firstline,lastline] == ['<,'>] or ['>,'<]
   " Assuming that SetBrush called from a visual-block selection!
   " Yank visual block into selected register (brush)
"   call Decho("yanking visual block into register ".b:drawit_brush)
   exe 'norm! gv"'.b:drawit_brush.'y'
  endif
"  call Dret("DrawIt#SetBrush : b:drawit_brush=".b:drawit_brush)
endfun

" ------------------------------------------------------------------------
" Modelines: {{{1
" vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
