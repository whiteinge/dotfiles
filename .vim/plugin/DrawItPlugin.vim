" DrawItPlugin.vim: a simple way to draw things in Vim -- just put this file in
"             your plugin directory, use \di to start (\ds to stop), and
"             just move about using the cursor keys.
"
"             You may also use visual-block mode to select endpoints and
"             draw lines, arrows, and ellipses.
"
" Date:			May 20, 2008
" Maintainer:	Charles E. Campbell, Jr.  <NdrOchipS@PcampbellAfamily.Mbiz>
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
" Required:  this script requires Vim 7.0 (or later) {{{1
" To Enable: simply put this plugin into your ~/.vim/plugin directory {{{2
"
" GetLatestVimScripts: 40 1 :AutoInstall: DrawIt.vim
"
"  (Zeph 3:1,2 WEB) Woe to her who is rebellious and polluted, the {{{1
"  oppressing city! She didn't obey the voice. She didn't receive
"  correction.  She didn't trust in Yahweh. She didn't draw near to her God.

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_DrawItPlugin")
 finish
endif
let g:loaded_DrawItPlugin = "v10"
let s:keepcpo             = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" DrChip Menu Support: {{{1
if has("gui_running") && has("menu") && &go =~ 'm'
 if !exists("g:DrChipTopLvlMenu")
  let g:DrChipTopLvlMenu= "DrChip."
 endif
 exe 'menu '.g:DrChipTopLvlMenu.'DrawIt.Start\ DrawIt<tab>\\di		<Leader>di'
endif

" ---------------------------------------------------------------------
" Public Interface: {{{1
if !hasmapto('<Plug>StartDrawIt')
  map <unique> <Leader>di <Plug>StartDrawIt
endif
map <silent> <Plug>StartDrawIt  :set lz<cr>:call DrawIt#StartDrawIt()<cr>:set nolz<cr>
com! -nargs=0 DIstart set lz|call DrawIt#StartDrawIt()|set nolz

if !hasmapto('<Plug>StopDrawIt')
  map <unique> <Leader>ds <Plug>StopDrawIt
endif
map <silent> <Plug>StopDrawIt :set lz<cr>:call DrawIt#StopDrawIt()<cr>:set nolz<cr>
com! -nargs=0 DIstop set lz|call DrawIt#StopDrawIt()|set nolz

" ---------------------------------------------------------------------
"  Cleanup And Modelines:
"  vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
