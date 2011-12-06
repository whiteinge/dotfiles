" Vim syntax file
" Language: Salt States template
" Maintainer: Seth House <seth@eseth.com>
" Last Change: 2011 Dec 05
"
" You probably want this in your .vimrc for now:
" au BufNewFile,BufRead *.sls set ft=sls

if exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'yaml'
endif

let b:current_syntax = ''
unlet b:current_syntax
runtime! syntax/yaml.vim

let b:current_syntax = ''
unlet b:current_syntax
syntax include @Yaml syntax/yaml.vim

let b:current_syntax = ''
unlet b:current_syntax
syntax include @Jinja syntax/django.vim

syn cluster djangoBlocks add=djangoTagBlock,djangoVarBlock,djangoComment,djangoComBlock
syn region djangoTagBlock start="{%" end="%}" contains=djangoStatement,djangoFilter,djangoArgument,djangoTagError display containedin=ALLBUT,@djangoBlocks
syn region djangoVarBlock start="{{" end="}}" contains=djangoFilter,djangoArgument,djangoVarError display containedin=ALLBUT,@djangoBlocks
syn region djangoComBlock start="{#" end="#}" contains=djangoTodo containedin=ALLBUT,@djangoBlocks

let b:current_syntax = "sls"
